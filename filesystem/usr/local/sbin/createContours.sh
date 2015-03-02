#!/bin/sh

dir=/var/www/mapnik-style/contours
merged=/var/www/tmp/merged.tif
hgtDir=/var/www
milestonefile=/var/www/milestones/createContours

mkdir -p ${dir}
createMerged.sh
for i in 1000 500 100 50 10
do
	file=${dir}/contours${i}
	if [ ! -f "${file}.shp" ]; then
		gdal_contour -i $i -snodata 32767 -a height $merged ${file}.shp
		shapeindex ${file}
	fi
done


