#!/bin/sh

merged=/var/www/tmp/merged.tif
hgtDir=/var/www
tmpDir=/var/www/tmp
milestonefile=/var/www/milestones/createContours
asweb="setuser www-data"

if [ ! -f "$milestonefile" ]; then
	$asweb psql -d gis -c "DROP TABLE contours;"
	mkdir -p "${tmpDir}/shp"
	first=true
	imported_something=false
	for f in $hgtDir/*.hgt
	do
	    if [ -f "$f"  ]; then
			name="${tmpDir}/shp/$(basename $f .hgt)"
			# Create contour lines with 10m spacing
			echo "Rendering contour lines from $f"
			gdal_contour -i 1000 -snodata 32767 -a height $f $name.shp
			# place the contour lines into the postgres database. create the table 
			# in case this is the first round, otherwise append.
			imported_something=true  
			echo "Placing contour lines into Postgres DB"
			if [ $first = true ]; then
				echo "Creating contour Table"
				shp2pgsql -c -I -g way $name contours | $asweb psql -q gis
				first=false
			else	
				#echo "append $append"
				# Even though we chose to append the data, shp2pgsql tries to create an index
				# which is already there. Is this a bug?
				shp2pgsql -a -I -g way $name contours | sed '/^CREATE INDEX/ d' | $asweb psql -q gis
			fi
			# remove all temporary files, i.e. .prj, .shx, .shp and .dbf
			rm $name.*
	    fi
	done
	echo "done $imported_something"
 	test !$imported_something && echo "No DEM data imported. Place *.hgt files into data directory in order to import."
	touch $milestonefile
fi

