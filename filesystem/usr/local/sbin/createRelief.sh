#!/bin/sh

tmpdir=/var/www/tmp
styledir=/var/www/mapnik-style
warped=${tmpdir}/warped.tif

createWarped.sh
if [ ! -f "${tmpdir}/reliefLZW.tif" ]; then
	gdaldem color-relief -co COMPRESS=LZW  ${tmpdir}/warped.tif ${styledir}/relief-colors.txt ${tmpdir}/reliefLZW.tif
fi
if [ ! -f "${styledir}/reliefMin.tif" ]; then
	gdal_translate -co COMPRESS=JPEG -outsize 10% 10% ${tmpdir}/reliefLZW.tif ${styledir}/reliefMin.tif
fi
if [ ! -f "${styledir}/reliefMed.tif" ]; then
	gdal_translate -co COMPRESS=JPEG -outsize 50% 50% ${tmpdir}/reliefLZW.tif ${styledir}/reliefMed.tif
fi
if [ ! -f "${styledir}/reliefMax.tif" ]; then
	gdal_translate -co COMPRESS=JPEG ${tmpdir}/reliefLZW.tif ${styledir}/reliefMax.tif
fi


