#!/bin/bash

source /usr/local/sbin/env.sh
merged=${tmpDir}/merged.tif
hgtDir=${mainDir}

mkdir -p ${tmpDir}

if [ ! -f $merged ]; then
	gdal_merge.py -co COMPRESS=lzw -v -o $merged ${hgtDir}/*.hgt
fi

