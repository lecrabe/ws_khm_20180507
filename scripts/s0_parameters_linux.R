####################################################################################################
####################################################################################################
## Set environment variables
## Contact remi.dannunzio@fao.org 
## 2018/05/04
####################################################################################################
####################################################################################################

####################################################################################################
options(stringsAsFactors = FALSE)

### Load necessary packages
library(raster)
library(rgeos)
library(ggplot2)
library(rgdal)

## Set the working directory
rootdir  <- "/media/dannunzio/OSDisk/Users/dannunzio/Documents/countries/cambodia/workshop_20180507/"
setwd(rootdir)
rootdir <- paste0(getwd(),"/")
gfcstore_dir  <- paste0("/media/dannunzio/lecrabe/gis_data/gfc_hansen_umd/gfc_2016/")

data_dir <- paste0(rootdir,"data/")

gadm_dir <- paste0(rootdir,"data/gadm/")
gfc_dir  <- paste0(rootdir,"data/gfc/")
lsat_dir <- paste0(rootdir,"data/mosaic_lsat/")
seg_dir  <- paste0(rootdir,"data/segments/")
dd_dir   <- paste0(rootdir,"data/dd_map/")
lc_dir   <- paste0(rootdir,"data/forest_mask/")

dir.create(gadm_dir,showWarnings = F)
dir.create(gfc_dir,showWarnings = F)
dir.create(lsat_dir,showWarnings = F)
dir.create(seg_dir,showWarnings = F)
dir.create(dd_dir,showWarnings = F)
dir.create(lc_dir,showWarnings = F)
