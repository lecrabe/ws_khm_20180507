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

aoi_4kml <- aoi
aoi_4kml@data <- aoi_4kml@data[,c("OBJECTID","ISO","NAME_4")]

writeOGR(aoi_4kml,
         paste0(gadm_dir,"gadm_",countrycode,"l4.kml"),
         paste0("gadm_",countrycode,"l4"),
         "KML",
         overwrite_layer = T)



## Select one province and export as KML
#sub_aoi <- aoi[aoi$NAME_4 == "Samret",]
sub_aoi <- aoi[aoi$NAME_4 == "Khyov",]
sub_aoi <- aoi[aoi$NAME_4 == "Pa Kalan",]

plot(getData('GADM',path=gadm_dir , country= countrycode, level=1))
plot(sub_aoi,add=T,col="red")

sub_aoi@data <- sub_aoi@data[,c("OBJECTID","ISO")]
writeOGR(sub_aoi,paste0(gadm_dir,"work_aoi_pa_kalan.kml"),"work_aoi_pa_kalan","KML",overwrite_layer = T)

