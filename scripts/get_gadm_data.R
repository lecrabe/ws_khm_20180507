####################################################################################################
####################################################################################################
## Get GADM data and extract one province of Cambodia
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

## Get List of Countries and select only Cambodia
(gadm_list  <- data.frame(getData('ISO3')))
listcodes   <- "KHM"
countrycode <- listcodes[1]

## Get GADM data and export as shapefile
aoi         <- getData('GADM',path=gadm_dir , country= countrycode, level=4)
writeOGR(aoi,
         paste0(gadm_dir,"gadm_",countrycode,"l4.shp"),
         paste0("gadm_",countrycode,"l4"),
         "ESRI Shapefile",
         overwrite_layer = T)

## Select one province and export as KML
#sub_aoi <- aoi[aoi$NAME_4 == "Samret",]
sub_aoi <- aoi[aoi$NAME_4 == "Khyov",]

plot(getData('GADM',path=gadm_dir , country= countrycode, level=1))
plot(sub_aoi,add=T,col="red")

sub_aoi@data <- sub_aoi@data[,c("OBJECTID","ISO")]
writeOGR(sub_aoi,paste0(gadm_dir,"work_aoi_khyov.kml"),"work_aoi_khyov","KML",overwrite_layer = T)

## Load inside Google Drive as a Fusion Table and note that FT ID
#my_fusion_table_id <- "1EiIBGwFKpZrlItVgkM01c4AOQ5Ms-MhIB8kbatBk"
my_fusion_table_id <- "1Y9AxDnjeTKpHrmnNRsT9wnZOumb8vX9vccc-l-Ik"