#!/bin/bash
cd /var/www
# if a region was handed in and it is different from before,
# start from scratch
if [ -n "$region" ] && [ ! -d "/var/www/region/$region" ]; then
	deleteDb.sh
	rm -rf \
		/var/www/milestones \
		/var/www/tmp \
		/var/www/*.pbf \
		/var/www/*.hgt \
		/var/www/mapnik-style/hillshade*.tif \
		/var/www/mapnik-style/relief*.tif \
		/var/www/mapnik-style/contours \
		/var/www/mod_tile


	mkdir -p /var/www/region/$region
fi

