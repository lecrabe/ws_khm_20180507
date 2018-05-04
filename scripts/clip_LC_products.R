####################################################################################################
####################################################################################################
## Clip available products for Cambodia
## Contact remi.dannunzio@fao.org 
## 2018/05/04
####################################################################################################
####################################################################################################

gfc_folder    <-  "/media/dannunzio/lecrabe/gis_data/gfc_hansen_umd/gfc_2016/"
rootdir <- "/media/dannunzio/OSDisk/Users/dannunzio/Documents/countries/cambodia/workshop_20180507/"
dest_dir      <-  paste0(rootdir,"data/gfc/")

dir.create(dest_dir)
time_start  <- Sys.time()

####################################################################################
####### GET COUNTRY BOUNDARIES
####################################################################################
aoi <- getData('GADM',path=paste0(rootdir,"/data/gadm/"), country= "KHM", level=2)
bb <- extent(aoi)

####################################################################################
####### CLIP GFC DATA TO CAMBODIA BOUNDARIES
####################################################################################
setwd(gfc_folder)

prefix <- "Hansen_GFC-2016-v1.4_"
tiles <- c("10N_010W","10N_020W")
list <- list()

for(tile in tiles){
  list <- append(list,list.files(".",pattern=tile))
}

types <- c("treecover2000","lossyear","gain","datamask")

for(type in types){
  print(type)
  to_merge <- paste(prefix,type,"_",tiles,".tif",sep = "",collapse = " ")
  system(sprintf("gdal_merge.py -o %s -v -co COMPRESS=LZW %s",
                 paste0(gfc_folder,"tmp_merge_",type,".tif"),
                 to_merge
                 ))
  
  system(sprintf("gdal_translate -ot Byte -projwin %s %s %s %s -co COMPRESS=LZW %s %s",
                 floor(bb@xmin),
                 ceiling(bb@ymax),
                 ceiling(bb@xmax),
                 floor(bb@ymin),
                 paste0(gfc_folder,"tmp_merge_",type,".tif"),
                 paste0(dest_dir,"gfc_lib_",type,".tif")
  ))
  
system(sprintf("rm %s",
               paste0(gfc_folder,"tmp_merge_",type,".tif")
               ))
  
}

time_products_global <- Sys.time() - time_start
