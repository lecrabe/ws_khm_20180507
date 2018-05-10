####################################################################################################
## Segmentation of the mosaic
## remi.dannunzio@fao.org
## 2018/02/05
####################################################################################################
####################################################################################################
options(stringsAsFactors=FALSE)



workdir <- lsat_dir

#################### PERFORM SEGMENTATION USING THE OTB-SEG ALGORITHM
params <- c(3,   # radius of smoothing (pixels)
            16,  # radius of proximity (pixels)
            0.1, # radiance threshold 
            50,  # iterations of algorithm
            5)  # segment minimum size (pixels)

tiles <- list.files(lsat_dir,pattern=glob2rx("*.tif"))

for(i in 1:length(tiles)){
  input <- tiles[i]
  system(sprintf("otbcli_MeanShiftSmoothing -in %s -fout %s -foutpos %s -spatialr %s -ranger %s -thres %s -maxiter %s",
                 paste0(workdir,input),
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
                 workdir
  ))
  
  system(sprintf("otbcli_LSMSSmallRegionsMerging -in %s -inseg %s -out %s -minsize %s -tilesizex 512 -tilesizey 512",
                 paste0(workdir,"tmp_smooth_",paste0(params,collapse = "_"),".tif"),
                 paste0(workdir,"tmp_seg_lsms_",paste0(params,collapse = "_"),".tif"),
                 paste0(seg_dir,"seg_lsms_tile_",i,"_param_",paste0(params,collapse = "_"),".tif"),
                 params[5]
  ))
  
  #################### CREATE GFC TREE COVER MAP in 2016 AT THRESHOLD (0 nodata, 1 no forest, 2 forest)
  system(sprintf("gdal_calc.py -A %s --co COMPRESS=LZW --overwrite --outfile=%s --calc=\"%s\"",
                 paste0(workdir,input),
                 paste0(seg_dir,"mask_mosaic_tile",i,".tif"),
                 "(A>0)"
  ))
  
  system(sprintf("rm -r %s",
                paste0(workdir,"tmp*.tif")))
}



# ######################### POLYGONIZE
# system(sprintf("gdal_polygonize.py -f \"ESRI Shapefile\" %s %s",
#                paste0(seg_dir,"seg_lsms_tile_1_param_",paste0(params,collapse = "_"),".tif"),
#                paste0(seg_dir,"seg_lsms_tile_1_",paste0(params,collapse = "_"),".shp")
# ))
