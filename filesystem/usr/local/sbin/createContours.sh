#!/bin/bash

set -e

source /usr/local/sbin/env.sh
hgtDir=${mainDir}
milestonefile=${milestoneDir}/createContours
name="${tmpDir}/contours"

if [ ! -f "$milestonefile" ]; then
	service postgresql start
	mkdir -p ${tmpDir}
	for i in 1000 100 10
	do
		setuser ${db_user} psql -d gis -c "DROP TABLE IF EXISTS contours$i;"
	done
  	first=true
  	imported_something=false
  	for f in $hgtDir/*.hgt
  	do
    		if [ -f "$f"  ]; then
    			for i in 1000 100 10
    			do
      				rm -f ${name}*
      				# Create contour lines with 10m spacing
      				echo "Rendering contour lines with ${i}m spacing from $f"
				gdal_contour -i $i -snodata 32767 -a height $f ${name}.shp
				# place the contour lines into the postgres database. create the table
				# in case this is the first round, otherwise append.
				imported_something=true
				echo "Placing contour lines into Postgres DB"
				if [ $first = true ]; then
					echo "Creating contour Table"
					shp2pgsql -c -I -g way ${name} contours$i \
						| setuser ${db_user} psql -q gis
				else
					#echo "append $append"
					# Even though we chose to append the data, shp2pgsql tries to create an index
					# which is already there. Is this a bug?
					shp2pgsql -a -I -g way ${name} contours$i \
						| sed '/^CREATE INDEX/ d' \
						| setuser ${db_user} psql -q gis
				fi
			done
			first=false
		fi
	done
 	test  $imported_something || echo "No DEM data imported. Place *.hgt files into data directory in order to import."
	touch $milestonefile
	service postgresql stop
fi

