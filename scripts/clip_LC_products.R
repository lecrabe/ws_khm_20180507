####################################################################################################
####################################################################################################
## Clip available products for Cambodia
## Contact remi.dannunzio@fao.org 
## 2018/05/04
####################################################################################################
####################################################################################################

time_start  <- Sys.time()

####################################################################################
####### GET COUNTRY BOUNDARIES
####################################################################################
aoi <- getData('GADM',path=paste0(rootdir,"/data/gadm/"), country= "KHM", level=2)
bb <- extent(aoi)

####################################################################################
####### CLIP GFC DATA TO CAMBODIA BOUNDARIES
####################################################################################
setwd(gfc_dir)

prefix <- "Hansen_GFC-2016-v1.4_"
tiles <- list.files(gfcstore_dir,pattern=glob2rx("*datamask*100E.tif"))
tilesx <- substr(tiles,31,38)

types <- c("treecover2000","lossyear","gain","datamask")

for(type in types){
  print(type)
  to_merge <- paste(prefix,type,"_",tilesx,".tif",sep = "")
  system(sprintf("gdal_merge.py -o %s -v -co COMPRESS=LZW %s",
                 paste0(gfc_dir,"tmp_merge_",type,".tif"),
                 paste0(gfcstore_dir,to_merge,collapse = " ")
                 ))

  system(sprintf("gdal_translate -ot Byte -projwin %s %s %s %s -co COMPRESS=LZW %s %s",
                 floor(bb@xmin),
                 ceiling(bb@ymax),
                 ceiling(bb@xmax),
                 floor(bb@ymin),
                 paste0(gfc_dir,"tmp_merge_",type,".tif"),
                 paste0(gfc_dir,"gfc_khm_",type,".tif")
  ))

system(sprintf("rm %s",
               paste0(gfc_dir,"tmp_merge_",type,".tif")
               ))
  print(to_merge)
}




#################### CREATE GFC TREE COVER MAP in 2000 AT THRESHOLD
system(sprintf("gdal_calc.py -A %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               paste0(gfc_dir,"gfc_khm_treecover2000.tif"),
               gfc_tc,
               paste0("(A>",gfc_threshold,")*A")
))

#################### CREATE GFC TREE COVER LOSS MAP AT THRESHOLD
system(sprintf("gdal_calc.py -A %s -B %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               paste0(gfc_dir,"gfc_khm_treecover2000.tif"),
               paste0(gfc_dir,"gfc_khm_lossyear.tif"),
               gfc_ly,
               paste0("(A>",gfc_threshold,")*B")
))

#################### CREATE GFC TREE COVER MAP IN 2016 AT THRESHOLD (0 nodata, 1 no forest, 2 forest)
system(sprintf("gdal_calc.py -A %s -B %s -C %s --co COMPRESS=LZW --outfile=%s --calc=\"%s\"",
               gfc_tc,
               gfc_ly,
               gfc_gn,
               gfc_16,
               "(C==1)*2+(C==0)*((B==0)*(A>0)*2+(B==0)*(A==0)*1+(B>0)*0)"
))

time_products_global <- Sys.time() - time_start
