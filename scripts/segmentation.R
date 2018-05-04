####################################################################################################
## Analyze DEM, Land Cover, Road accessibility, Water + aux to identify zones suitable for camp
## remi.dannunzio@fao.org & rashed.jalal@fao.org
## 2018/02/05
####################################################################################################
####################################################################################################
options(stringsAsFactors=FALSE)

library(Hmisc)
library(sp)
library(rgdal)
library(raster)
library(plyr)
library(foreign)
library(rgeos)
library(glcm)

#################### Load Landsat_8 mosaic from SEPAL
workdir <- "/home/dannunzio/downloads/liberia_2016/"
setwd(workdir)
#################### PERFORM SEGMENTATION USING THE OTB-SEG ALGORITHM
params <- c(3,   # radius of smoothing (pixels)
            16,  # radius of proximity (pixels)
            0.1, # radiance threshold 
            50,  # iterations of algorithm
            10)  # segment minimum size (pixels)

tiles <- list.files(".",pattern=glob2rx("liberia*.tif"))

for(i in 1:length(tiles)){
  input <- tiles[i]
  system(sprintf("otbcli_MeanShiftSmoothing -in %s -fout %s -foutpos %s -spatialr %s -ranger %s -thres %s -maxiter %s",
                 input,
                 paste0(workdir,"tmp_smooth_",paste0(params,collapse = "_"),".tif"),
                 paste0(workdir,"tmp_position_",paste0(params,collapse = "_"),".tif"),
                 params[1],
                 params[2],
                 params[3],
                 params[4]
  ))
  
  system(sprintf("otbcli_LSMSSegmentation -in %s -inpos %s -out %s -spatialr %s -ranger %s -minsize 0 -tmpdir %s -tilesizex 512 -tilesizey 512",
                 paste0(workdir,"tmp_smooth_",paste0(params,collapse = "_"),".tif"),
                 paste0(workdir,"tmp_position_",paste0(params,collapse = "_"),".tif"),
                 paste0(workdir,"tmp_seg_lsms_",paste0(params,collapse = "_"),".tif"),
                 params[1],
                 params[2],
                 "."
  ))
  
  system(sprintf("otbcli_LSMSSmallRegionsMerging -in %s -inseg %s -out %s -minsize %s -tilesizex 512 -tilesizey 512",
                 paste0(workdir,"tmp_smooth_",paste0(params,collapse = "_"),".tif"),
                 paste0(workdir,"tmp_seg_lsms_",paste0(params,collapse = "_"),".tif"),
                 paste0(workdir,"seg_lsms_tile_",i,"_param_",paste0(params,collapse = "_"),".tif"),
                 params[5]
  ))
}

######################### POLYGONIZE
system(sprintf("gdal_polygonize.py -f \"ESRI Shapefile\" %s %s",
               paste0(workdir,"seg_lsms_",paste0(params,collapse = "_"),".tif"),
               paste0(workdir,"seg_lsms_",paste0(params,collapse = "_"),".shp")
))