#!/bin/bash

source /usr/local/sbin/env.sh

warped=${tmpDir}/warped.tif

createMerged.sh
if [ ! -f $warped ]; then
	gdalwarp -co COMPRESS=lzw -of GTiff -co "TILED=YES" -srcnodata 32767 -t_srs "+proj=merc +ellps=sphere +R=6378137 +a=6378137 +units=m" -rcs -order 3 -tr 30 30 -multi ${tmpDir}/merged.tif ${warped}
fi

