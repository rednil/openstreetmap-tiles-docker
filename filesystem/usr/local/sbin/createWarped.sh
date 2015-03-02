#!/bin/sh
tmpdir=/var/www/tmp
warped=${tmpdir}/warped.tif

createMerged.sh
if [ ! -f $warped ]; then
	gdalwarp -co COMPRESS=lzw -of GTiff -co "TILED=YES" -srcnodata 32767 -t_srs "+proj=merc +ellps=sphere +R=6378137 +a=6378137 +units=m" -rcs -order 3 -tr 30 30 -multi ${tmpdir}/merged.tif ${warped}
fi

