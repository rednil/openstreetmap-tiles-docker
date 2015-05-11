#!/bin/bash

source /usr/local/sbin/env.sh

tmpDir=/var/www/tmp
styleDir=/var/www/mapnik-style
warped=${tmpDir}/warped.tif

createWarped.sh
if [ ! -f "${tmpDir}/reliefLZW.tif" ]; then
	gdaldem color-relief -co COMPRESS=LZW  ${tmpDir}/warped.tif ${styleDir}/relief-colors.txt ${tmpDir}/reliefLZW.tif
fi
if [ ! -f "${styleDir}/reliefMin.tif" ]; then
	gdal_translate -co COMPRESS=JPEG -outsize 10% 10% ${tmpDir}/reliefLZW.tif ${styleDir}/reliefMin.tif
fi
if [ ! -f "${styleDir}/reliefMed.tif" ]; then
	gdal_translate -co COMPRESS=JPEG -outsize 50% 50% ${tmpDir}/reliefLZW.tif ${styleDir}/reliefMed.tif
fi
if [ ! -f "${styleDir}/reliefMax.tif" ]; then
	gdal_translate -co COMPRESS=JPEG ${tmpDir}/reliefLZW.tif ${styleDir}/reliefMax.tif
fi


