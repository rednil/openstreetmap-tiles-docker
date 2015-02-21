#!/bin/sh

tmpdir=/var/www/tmp
merged=${tmpdir}/merged.tif
hgtDir=/var/www

mkdir -p ${tmpdir}

if [ ! -f $merged ]; then
	gdal_merge.py -co COMPRESS=lzw -v -o $merged ${hgtDir}/*.hgt
fi

