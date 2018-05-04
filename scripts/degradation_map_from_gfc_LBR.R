####################################################################################################
####################################################################################################
## Use a decision tree to integrate raster values inside segments
## Contact remi.dannunzio@fao.org 
## 2017/11/02
####################################################################################################
####################################################################################################
time_start <- Sys.time() 

root_dir <- "/media/dannunzio/OSDisk/Users/dannunzio/Documents/countries/liberia/data/"
setwd(root_dir)

dd_dir <- paste0(root_dir,"dd_map/")
seg_dir  <- paste0(root_dir,"segments/")

#################### GFC PRODUCTS
gfc_threshold <- 30

gfc_tc       <- paste0(root_dir,"gfc_2016/gfc_lib_th",gfc_threshold,"_tc.tif")
gfc_ly       <- paste0(root_dir,"gfc_2016/gfc_lib_th",gfc_threshold,"_ly.tif")
gfc_gn       <- paste0(root_dir,"gfc_2016/gfc_lib_gain.tif")
gfc_16       <- paste0(root_dir,"gfc_2016/gfc_lib_th",gfc_threshold,"_F_2016.tif")

#################### GEOVILLE MAP
map_14       <- paste0(root_dir,"FDA_data/Geoville_map/Liberia_landcover_forest_map_10m_v1.tif")       

#################### CREATE GFC TREE COVER MAP in 2000 AT THRESHOLD
system(sprintf("gdal_calc.py -A %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               paste0(root_dir,"gfc_2016/gfc_lib_treecover2000.tif"),
               gfc_tc,
               paste0("(A>",gfc_threshold,")*A")
))

#################### CREATE GFC TREE COVER MAP AT THRESHOLD
system(sprintf("gdal_calc.py -A %s -B %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               paste0(root_dir,"gfc_2016/gfc_lib_treecover2000.tif"),
               paste0(root_dir,"gfc_2016/gfc_lib_lossyear.tif"),
               gfc_ly,
               paste0("(A>",gfc_threshold,")*B")
))

#################### CREATE GFC TREE COVER MAP in 2016 AT THRESHOLD (0 nodata, 1 no forest, 2 forest)
system(sprintf("gdal_calc.py -A %s -B %s -C %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               gfc_tc,
               gfc_ly,
               gfc_gn,
               gfc_16,
               "(C==1)*2+(C==0)*((B==0)*(A>0)*2+(B==0)*(A==0)*1+(B>0)*0)"
))

#################### CREATE A COLR TABLE FOR THE OUTPUT MAP
my_classes <- c(0,1,2,3,4)
my_colors  <- col2rgb(c("black","grey","darkgreen","red","orange"))

pct <- data.frame(cbind(my_classes,
                        my_colors[1,],
                        my_colors[2,],
                        my_colors[3,]))

write.table(pct,paste0(dd_dir,"color_table.txt"),row.names = F,col.names = F,quote = F)

#################### LOOP THROUGH TILES
list_tiles <- list.files(seg_dir,pattern=glob2rx("seg*.tif"))
time_start <- Sys.time() 
for(i in 1:length(list_tiles)){
  
  the_tile     <- list_tiles[i]
  
  the_segments <- paste0(seg_dir,the_tile)

  #################### ALIGN PRODUCTS WITH SEGMENTS
  mask   <- the_segments
  proj   <- proj4string(raster(mask))
  extent <- extent(raster(mask))
  res    <- res(raster(mask))[1]
  
  
  #################### ALIGN GFC TREE COVER WITH SEGMENTS
  input  <- gfc_tc
  ouput  <- paste0(dd_dir,"tmp_tc_tile.tif")
  
  system(sprintf("gdalwarp -co COMPRESS=LZW -t_srs \"%s\" -te %s %s %s %s -tr %s %s %s %s -overwrite",
                 proj4string(raster(mask)),
                 extent(raster(mask))@xmin,
                 extent(raster(mask))@ymin,
                 extent(raster(mask))@xmax,
                 extent(raster(mask))@ymax,
                 res(raster(mask))[1],
                 res(raster(mask))[2],
                 input,
                 ouput
  ))
  
  #################### ALIGN GFC Forest 2016 WITH SEGMENTS
  input  <- gfc_16
  ouput  <- paste0(dd_dir,"tmp_f16_tile.tif")
  
  system(sprintf("gdalwarp -co COMPRESS=LZW -t_srs \"%s\" -te %s %s %s %s -tr %s %s %s %s -overwrite",
                 proj4string(raster(mask)),
                 extent(raster(mask))@xmin,
                 extent(raster(mask))@ymin,
                 extent(raster(mask))@xmax,
                 extent(raster(mask))@ymax,
                 res(raster(mask))[1],
                 res(raster(mask))[2],
                 input,
                 ouput
  ))
  
  #################### ALIGN GFC LOSSYEAR WITH SEGMENTS
  input  <- gfc_ly
  ouput  <- paste0(dd_dir,"tmp_ly_tile.tif")

  system(sprintf("gdalwarp -co COMPRESS=LZW -t_srs \"%s\" -te %s %s %s %s -tr %s %s %s %s -overwrite",
                 proj4string(raster(mask)),
                 extent(raster(mask))@xmin,
                 extent(raster(mask))@ymin,
                 extent(raster(mask))@xmax,
                 extent(raster(mask))@ymax,
                 res(raster(mask))[1],
                 res(raster(mask))[2],
                 input,
                 ouput
  ))
  

  #################### ALIGN GEOVILLE MAP WITH SEGMENTS
  input  <- map_14
  ouput  <- paste0(dd_dir,"tmp_lcmap_tile.tif")

  system(sprintf("gdalwarp -co COMPRESS=LZW -t_srs \"%s\" -te %s %s %s %s -tr %s %s %s %s -overwrite",
                 proj4string(raster(mask)),
                 extent(raster(mask))@xmin,
                 extent(raster(mask))@ymin,
                 extent(raster(mask))@xmax,
                 extent(raster(mask))@ymax,
                 res(raster(mask))[1],
                 res(raster(mask))[2],
                 input,
                 ouput
  ))
  
  
  ####################################################################################################
  #################### DECISION TREE 
  ####################################################################################################

  #################### ZONAL FOR LC GEOVILLE MAP
  system(sprintf("oft-his -i %s -o %s -um %s -maxval %s",
                 paste0(dd_dir,"tmp_lcmap_tile.tif"),
                 paste0(dd_dir,"stat_lcmap_tile.txt"),
                 the_segments,
                 25
  ))
  
  #################### ZONAL FOR GFC TREECOVER
  system(sprintf("oft-his -i %s -o %s -um %s -maxval %s",
                 paste0(dd_dir,"tmp_tc_tile.tif"),
                 paste0(dd_dir,"stat_tc_tile.txt"),
                 the_segments,
                 100
  ))
  
  #################### ZONAL FOR GFC LOSSYEAR
  system(sprintf("oft-his -i %s -o %s -um %s -maxval %s",
                 paste0(dd_dir,"tmp_ly_tile.tif"),
                 paste0(dd_dir,"stat_ly_tile.txt"),
                 the_segments,
                 16
  ))
  
  #################### ZONAL FOR GFC FOREST 2016
  system(sprintf("oft-his -i %s -o %s -um %s -maxval %s",
                 paste0(dd_dir,"tmp_f16_tile.tif"),
                 paste0(dd_dir,"stat_f16_tile.txt"),
                 the_segments,
                 2
  ))
  
  #################### READ THE ZONAL STATS
  df_gfc_tc  <- read.table(paste0(dd_dir,"stat_tc_tile.txt"))
  df_gfc_ly  <- read.table(paste0(dd_dir,"stat_ly_tile.txt"))
  df_gfc_16  <- read.table(paste0(dd_dir,"stat_f16_tile.txt"))
  df_lcmap   <- read.table(paste0(dd_dir,"stat_lcmap_tile.txt"))
  
  names(df_gfc_tc)  <- c("clump_id","total_gfc_tc",paste0("tc_",0:100))
  names(df_gfc_ly)  <- c("clump_id","total_gfc_ly",paste0("ly_",0:16))
  names(df_gfc_16)  <- c("clump_id","total_gfc_gn",paste0("gn_",0:2))
  names(df_lcmap )  <- c("clump_id","total_gfc_lc",paste0("lc_",0:25))
  
  head(df_gfc_16)
  ####### INITIATE THE OUT DATAFRAME
  df <- df_gfc_tc[,c("clump_id","total_gfc_tc")]
  
  ####### CALCULATE MAJORITY CLASS FOR EACH THEMATIC PRODUCT
  df$mode_lc <- c(0:25)[max.col(df_lcmap[,paste0("lc_",0:25)])]
  
  ####### SETUP THE OUTPUT
  df$ddclass  <- 0 
  
  ####### NON FOREST == 1
  tryCatch({
    df[rowSums(df_gfc_tc[,paste0("tc_",30:100)]) <  0.3*df$total_gfc_tc , ]$ddclass <- 1
  },error=function(e){cat("Not relevant\n")})
  
  ####### FOREST == 2
  tryCatch({
    df[rowSums(df_gfc_tc[,paste0("tc_",30:100)]) >= 0.3*df$total_gfc_tc & df_gfc_16$gn_2 >= 0.3*df$total_gfc_tc, ]$ddclass <- 2
  },error=function(e){cat("Not relevant\n")})
  
  ####### DEGRADATION == 4
  tryCatch({
    df[rowSums(df_gfc_tc[,paste0("tc_",30:100)]) >= 0.3*df$total_gfc_tc & df_gfc_16$gn_2 >= 0.3*df$total_gfc_tc & rowSums(df_gfc_ly[,paste0("ly_",1:16)]) > 0.1 *df$total_gfc_tc,]$ddclass <- 4
  },error=function(e){cat("Not relevant\n")})
  
  ####### DEFORESTATION == 3
  tryCatch({
    df[rowSums(df_gfc_tc[,paste0("tc_",30:100)]) >= 0.3*df$total_gfc_tc & df_gfc_16$gn_2 <  0.3*df$total_gfc_tc & rowSums(df_gfc_ly[,paste0("ly_",1:16)]) > 0 ,]$ddclass <- 3
  },error=function(e){cat("Not relevant\n")})
  
  ####### NO DATA == 0
  tryCatch({
    df[df_lcmap$lc_0 > 0  , ]$ddclass <- 0
  },error=function(e){cat("Not relevant\n")})
  
  table(df$ddclass)
  
  write.table(df[,c("clump_id","total_gfc_tc","ddclass")],
              paste0(dd_dir,"stat_reclass.txt"),row.names = F,col.names = F)
  
  
  ################################################################################
  #################### Reclassify 
  system(sprintf("(echo %s; echo 1; echo 1; echo 3; echo 0) | oft-reclass  -oi %s  -um %s %s",
                 paste0(dd_dir,"stat_reclass.txt"),
                 paste0(dd_dir,"tmp_reclass.tif"),
                 the_segments,
                 the_segments
  ))
  
  ################################################################################
  #################### CONVERT TO BYTE
  system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
                 paste0(dd_dir,"tmp_reclass.tif"),
                 paste0(dd_dir,"tmp_reclass_byte.tif")
  ))
  
  ################################################################################
  #################### Add pseudo color table to result
  system(sprintf("(echo %s) | oft-addpct.py %s %s",
                 paste0(dd_dir,"color_table.txt"),
                 paste0(dd_dir,"tmp_reclass_byte.tif"),
                 paste0(dd_dir,"tmp_pct_decision_tree.tif")
  ))
  
  ################################################################################
  #################### COMPRESS
  system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
                 paste0(dd_dir,"tmp_pct_decision_tree.tif"),
                 paste0(dd_dir,"tile_",i,"_decision_tree.tif")
  ))
  
  system(sprintf("rm %s",
                 paste0(dd_dir,"tmp*.tif")))
  
  system(sprintf("rm %s",
                 paste0(dd_dir,"stat*.txt")))

}
time_decision_tree <- Sys.time() - time_start

#############################################################
### MERGE AS VRT
system(sprintf("gdalbuildvrt %s %s",
               paste0(dd_dir,"dd_map_liberia.vrt"),
               paste0(dd_dir,"tile_*_decision_tree.tif")
))

################################################################################
#################### Add pseudo color table to result
system(sprintf("(echo %s) | oft-addpct.py %s %s",
               paste0(dd_dir,"color_table.txt"),
               paste0(dd_dir,"dd_map_liberia.vrt"),
               paste0(dd_dir,"tmp_merge_pct.tif")
))

################################################################################
#################### COMPRESS
system(sprintf("gdal_translate -ot Byte -co COMPRESS=LZW %s %s",
               paste0(dd_dir,"tmp_merge_pct.tif"),
               paste0(dd_dir,"dd_map_liberia.tif")
))

#############################################################
### CLEAN
system(sprintf("rm %s",
               paste0(dd_dir,"tmp*.tif")
))
