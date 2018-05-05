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
tiles <- list.files(gfc_dir,pattern="datamask")
tilesx <- substr(tiles,31,38)

types <- c("treecover2000","lossyear","gain","datamask")

for(type in types){
  print(type)
  to_merge <- paste(prefix,type,"_",tilesx,".tif",sep = "")
  system(sprintf("gdal_merge.py -o %s -v -co COMPRESS=LZW %s",
                 paste0(gfc_dir,"tmp_merge_",type,".tif"),
                 paste0(gfc_dir,to_merge,collapse = " ")
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

time_products_global <- Sys.time() - time_start
