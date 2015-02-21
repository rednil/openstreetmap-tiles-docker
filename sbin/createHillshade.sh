#!/bin/sh

tmpdir=/var/www/tmp
styledir=/var/www/mapnik-style
warped=${tmpdir}/warped.tif

createWarped.sh
if [ ! -f "${styledir}/hillshadeMax.tif" ]; then
	gdaldem hillshade -co COMPRESS=LZW -co PREDICTOR=2 ${tmpdir}/warped.tif ${styledir}/hillshadeMax.tif
fi
if [ ! -f "${styledir}/hillshadeMin.tif" ]; then
	gdal_translate -outsize 10% 10% ${styledir}/hillshadeMax.tif ${styledir}/hillshadeMin.tif
fi
if [ ! -f "${styledir}/hillshadeMed.tif" ]; then
	gdal_translate -outsize 50% 50% ${styledir}/hillshadeMax.tif ${styledir}/hillshadeMed.tif
fi

