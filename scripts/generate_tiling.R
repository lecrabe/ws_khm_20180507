####################################################################################################
####################################################################################################
## Generate tiling over an AOI
####################################################################################################
####################################################################################################
options(stringsAsFactors = FALSE)

### Load necessary packages
library(raster)
library(rgeos)
library(ggplot2)
library(rgdal)
library(maptools)

## Set the working directory
workdir  <- paste0("data/")
setwd(workdir)
dir.create("tiling")

## Get List of Countries
(gadm_list  <- data.frame(getData('ISO3')))
listcodes   <- "KHM"

countrycode <- listcodes[1]
aoi         <- getData('GADM',path='tiling/', country= countrycode, level=0)


### What grid size do we need ? 
grid_size <- 20000          ## in meters

grid_deg <- grid_size/111320 
buffer <- buffer(aoi,grid_deg)
plot(aoi)
plot(buffer,add=T)
### Create a set of regular SpatialPoints on the extent of the created polygons  
sqr <- SpatialPoints(makegrid(buffer,offset=c(0.5,0.5),cellsize = grid_deg))

### Convert points to a square grid
grid <- points2grid(sqr)

### Convert the grid to SpatialPolygonDataFrame
SpP_grd <- as.SpatialPolygons.GridTopology(grid)

sqr_df <- SpatialPolygonsDataFrame(
  Sr=SpP_grd,
  data=data.frame(rep(1,length(SpP_grd))),
  match.ID=F)

### Assign the right projection
proj4string(sqr_df) <- proj4string(aoi)
sqr_df_selected <- sqr_df[aoi,]

### Plot the results
plot(sqr_df_selected)
plot(aoi,add=T)

### Give the output a decent name, with unique ID
names(sqr_df_selected) <- "tileID"
sqr_df_selected@data$tileID <-row(sqr_df_selected@data)[,1]

### Check how many tiles will be created
nrow(sqr_df_selected@data)

subset <- sqr_df_selected[sample(1:nrow(sqr_df_selected@data),11),]
plot(subset)
plot(aoi,add=T)

#######################################################################
### PART III: Export as KML
#######################################################################
base_sqr <- paste("tiles_",countrycode,sep="")
writeOGR(obj=sqr_df_selected,dsn=paste("tiling/",base_sqr,".kml",sep=""),layer=base_sqr,driver = "KML",overwrite_layer = T)

all_tiles <- readOGR("tiling/tiles_KHM.kml")
tile <- all_tiles[all_tiles$tileID == 112,]
tile <- tile[,c("tileID")]
writeOGR(tile,paste0("tiling/tile_known_degrad.kml"),paste0("tile_known_degrad"),"KML",overwrite_layer = T)

#### Selection by hand
tiles <- readOGR("tiling/selected_12tiles.shp")
plot(tile)

for(operator in tiles$operator){
  sub <- tiles[tiles$operator == operator,]
  writeOGR(sub,paste0("tiling/tile_",operator,".kml"),paste0("tile_",operator,".kml"),"KML",overwrite_layer = T)
}
