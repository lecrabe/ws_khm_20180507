####################################################################################################
####################################################################################################
## Set environment variables
## Contact remi.dannunzio@fao.org 
## 2018/05/04
####################################################################################################
####################################################################################################

####################################################################################################
options(stringsAsFactors = FALSE)

packages <- function(x){
  x <- as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}
packages(gfcanalysis)
packages(Hmisc)

### Load necessary packages
library(raster)
library(rgeos)
library(ggplot2)
library(rgdal)

## Set the working directory
rootdir  <- "~/ws_khm_20180507/"
setwd(rootdir)
rootdir <- paste0(getwd(),"/")

data_dir <- paste0(rootdir,"data/")

gfcstore_dir  <- paste0("~/downloads/gfc_2016/")
gadm_dir <- paste0(rootdir,"data/gadm/")
gfc_dir  <- paste0(rootdir,"data/gfc/")
lsat_dir <- paste0(rootdir,"data/mosaic_lsat/")
seg_dir  <- paste0(rootdir,"data/segments/")
dd_dir   <- paste0(rootdir,"data/dd_map/")

dir.create(gadm_dir,showWarnings = F)
dir.create(gfcstore_dir,showWarnings = F)
dir.create(gfc_dir,showWarnings = F)
dir.create(lsat_dir,showWarnings = F)
dir.create(seg_dir,showWarnings = F)
dir.create(dd_dir,showWarnings = F)

#################### GFC PRODUCTS
gfc_threshold <- 30
