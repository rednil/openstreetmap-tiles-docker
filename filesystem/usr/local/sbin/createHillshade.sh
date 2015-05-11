#!/bin/bash

source /usr/local/sbin/env.sh

warped=${tmpDir}/warped.tif

createWarped.sh
if [ ! -f "${styleDir}/hillshadeMax.tif" ]; then
	gdaldem hillshade -co COMPRESS=LZW -co PREDICTOR=2 ${tmpDir}/warped.tif ${styleDir}/hillshadeMax.tif
fi
if [ ! -f "${styleDir}/hillshadeMin.tif" ]; then
	gdal_translate -outsize 10% 10% ${styleDir}/hillshadeMax.tif ${styleDir}/hillshadeMin.tif
fi
if [ ! -f "${styleDir}/hillshadeMed.tif" ]; then
	gdal_translate -outsize 50% 50% ${styleDir}/hillshadeMax.tif ${styleDir}/hillshadeMed.tif
fi

