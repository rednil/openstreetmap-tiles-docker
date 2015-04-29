#!/bin/sh

merged=/var/www/tmp/merged.tif
hgtDir=/var/www
tmpDir=/var/www/tmp
milestonefile=/var/www/milestones/createContours
asweb="setuser www-data"
name="${tmpDir}/contours"

if [ ! -f "$milestonefile" ]; then
	for i in 1000 100 10
	do
		$asweb psql -d gis -c "DROP TABLE contours$i;"
	done
  	first=true
  	imported_something=false
  	for f in $hgtDir/*.hgt
  	do
    		if [ -f "$f"  ]; then
    			for i in 1000 100 10
    			do
      				rm ${name}*
      				# Create contour lines with 10m spacing
      				echo "Rendering contour lines with ${i}m spacing from $f"
				gdal_contour -i $i -snodata 32767 -a height $f ${name}.shp
				# place the contour lines into the postgres database. create the table
				# in case this is the first round, otherwise append.
				imported_something=true
				echo "Placing contour lines into Postgres DB"
				if [ $first = true ]; then
					echo "Creating contour Table"
					shp2pgsql -c -I -g way ${name} contours$i | $asweb psql -q gis
				else
					#echo "append $append"
					# Even though we chose to append the data, shp2pgsql tries to create an index
					# which is already there. Is this a bug?
					shp2pgsql -a -I -g way ${name} contours$i | sed '/^CREATE INDEX/ d' | $asweb psql -q gis
				fi
			done
			first=false
		fi
	done
 	test  $imported_something || echo "No DEM data imported. Place *.hgt files into data directory in order to import."
	touch $milestonefile
fi

