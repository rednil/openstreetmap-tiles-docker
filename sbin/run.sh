#!/bin/sh

##
# Run OpenStreetMap tile server operations
#

# Command prefix that runs the command as the web user
asweb="setuser www-data"

die () {
    msg=$1
    echo "FATAL ERROR: " msg > 2
    exit
}

_startservice () {
	mkdir -p /var/www/mod_tile
	if [ ! -d "/var/www/html" ]; then
		echo "Copying html from /usr/local/src to /var/www"
		cp -r /usr/local/src/html /var/www
	fi
	chown -R www-data.www-data /var/www/mod_tile /var/www/html
    sv start $1 || die "Could not start $1"
}
_stopservice (){
	sv stop $1 || die "Could not stop $1"
}
start_db () {
    _startservice postgresql
}
init_db () {
    echo "Initialising postgresql"
    if [ -d /var/www/postgresql/9.3/main ] && [ $( ls -A /var/www/postgresql/9.3/main | wc -c ) -ge 0 ]
    then
        die "Initialisation failed: the directory is not empty: /var/www/postgresql/9.3/main"
    fi

    mkdir -p /var/www/postgresql/9.3/main && chown -R postgres /var/www/postgresql/
    sudo -u postgres -i /usr/lib/postgresql/9.3/bin/initdb --pgdata /var/www/postgresql/9.3/main
    ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /var/www/postgresql/9.3/main/server.crt
    ln -s /etc/ssl/private/ssl-cert-snakeoil.key /var/www/postgresql/9.3/main/server.key
}

create_user () {
    USER=www-data
    echo "Creating user $USER"
    setuser postgres createuser -s $USER
}

create_db () {
    dbname=gis
    echo "Creating database $dbname"
    cd /var/www

    # Create the database
    setuser postgres createdb -O www-data $dbname

    # Install the Postgis schema
    $asweb psql -d $dbname -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql
	
	#Install the spatial_ref_sys table
	$asweb psql -d $dbname -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql

    # Set the correct table ownership
    $asweb psql -d $dbname -c 'ALTER TABLE geometry_columns OWNER TO "www-data"; ALTER TABLE spatial_ref_sys OWNER TO "www-data";'

    # Add the 900913 Spatial Reference System
    $asweb psql -d $dbname -f /usr/local/share/osm2pgsql/900913.sql
}
fromscratch (){
	#_stopservice postgresql would do a smart shutdown, which most times doesn't succeed
	/etc/init.d/postgresql stop
	rm -rf /var/www/postgresql
	drop_dem
	init_db
	start_db
	create_user
	create_db
	import
	clear_cache
	start_services
}
redo_fromscratch () {
	mv /var/www/imported/* /var/www/
	fromscratch
}
import_style (){
	styledir=/var/www/mapnik-style
	if [ ! -d "$styledir" ]; then
		echo "Copying /usr/local/src/mapnik/style to $styledir"
		cp -r /usr/local/src/mapnik-style $styledir
		chown -R www-data.www-data $styledir
	fi
	if [ ! -d "$styledir/data" ]; then
		cd $styledir
		echo "Executing $styledir/get-shapefiles.sh"
		$asweb ./get-shapefiles.sh
		rm data/*.zip data/*.tgz
		cd /var/www
	fi
	echo "Translating project.yaml to osm.xml in $styledir"
	$styledir/scripts/yaml2mml.py <$styledir/project.yaml >$styledir/project.mml
	carto $styledir/project.mml >$styledir/osm.xml
}

import (){
	import_osm
	import_dem
	import_style
}
import_osm (){
	start_db
	imported_something=false
	for f in /var/www/*.osm
	do
	    if [ -f "$f" ]; then
		mkdir -p /var/www/imported
		echo "Importing ${import} into gis"
    		echo "$OSM_IMPORT_CACHE" | grep -P '^[0-9]+$' || \
        		die "Unexpected cache type: expected an integer but found: ${OSM_IMPORT_CACHE}"
    		number_processes=`nproc`;
    		if test $number_processes -ge 8; then # Limit to 8 to prevent overwhelming pg with connections
        		number_processes=8;
    		fi
    		$asweb osm2pgsql --slim --cache $OSM_IMPORT_CACHE --database gis --number-processes $number_processes $f
		mv $f /var/www/imported
		imported_something=true
	    fi
	done
 	test $imported_something || echo "No OSM data imported. Place *.osm or *.pbf files into data directory in order to import."
}
import_dem (){
	import_contours
	import_relief
}
import_contours (){
	start_db
	mkdir -p /var/www/tmp	
	imported_something=false
	for f in /var/www/*.hgt
	do
	    if [ -f "$f"  ]; then
		name="$(dirname $f)/tmp/$(basename $f .hgt)"
		# Create contour lines with 10m spacing
		echo "Rendering contour lines from $f"
		gdal_contour -i 10 -snodata 32767 -a height $f $name.shp
		# place the contour lines into the postgres database. create the table 
		# in case this is the first round, otherwise append.
		imported_something=true  
		echo "Placing contour lines into Postgres DB"
		if $asweb psql -d gis -c '\dt' | grep -w contours;
		then
			echo "append"
			# Even though we chose to append the data, shp2pgsql tries to create an index
                        # which is already there. Is this a bug?
			shp2pgsql -a -I -g way $name contours | sed '/^CREATE INDEX/ d' | $asweb psql -q gis
		else	
			echo "create table"
			shp2pgsql -c -I -g way $name contours | $asweb psql -q gis
		fi
		# remove all temporary files, i.e. .prj, .shx, .shp and .dbf
		rm $name.*
	    fi
	done
	echo "done $imported_something"
 	test $imported_something || echo "No DEM data imported. Place *.hgt files into data directory in order to import."
	_dem_to_imported
}
reimport_contours (){
	start_db
	drop_contours
	_dem_from_imported
	import_contours
	_dem_to_imported
	clear_cache
}
carto2mapnik (){
	styledir=/var/www/mapnik-style
	$styledir/scripts/yaml2mml.py <$styledir/project.yaml >$styledir/project.mml
	carto $styledir/project.mml >$styledir/osm.xml
	clear_cache
}
import_relief (){
	drop_relief
	_dem_from_imported
	mkdir -p /var/www/tiff
	mkdir -p /var/www/tmp
	rm -rf /var/www/tmp/merged.tif
	rm -rf /var/www/tmp/warped.tif
	gdal_merge.py \
		-co COMPRESS=lzw \
		-v -o \
		/var/www/tmp/merged.tif \
		/var/www/*.hgt
	gdalwarp \
		-co COMPRESS=lzw \
		-of GTiff \ 
		-co "TILED=YES" \
		-srcnodata 32767 \
		-t_srs "+proj=merc +ellps=sphere +R=6378137 +a=6378137 +units=m" \
		-rcs \
		-order 3 \
		-tr 30 30 \
		-multi \
		/var/www/tmp/merged.tif \
		/var/www/tmp/warped.tif
	gdaldem hillshade \
		-co COMPRESS=LZW \
		-co PREDICTOR=2 \
		/var/www/tmp/warped.tif \
		/var/www/mapnik-style/hillshade.tif
	gdaldem color-relief \
		-co COMPRESS=JPEG \
		/var/www/tmp/warped.tif \
		/var/www/mapnik-style/relief-colors.txt \
		/var/www/mapnik-style/relief.tif
	rm -rf /var/www/tmp/merged.tif
    rm -rf /var/www/tmp/warped.tif
	_dem_to_imported
}
_dem_to_imported (){
	mkdir -p /var/www/imported
	mv /var/www/*.hgt /var/www/imported/
}
_dem_from_imported (){
	mv /var/www/imported/*.hgt /var/www/
}
reimport_relief (){
	import_relief
	clear_cache	
}
clear_cache (){
	sv stop renderd
	rm -rf /var/www/mod_tile/*
	_startservice renderd
}
drop_contours (){
	$asweb psql -d gis -c "DROP TABLE contours;"
}
drop_dem (){
	drop_relief
	drop_contours
}
drop_relief (){
	rm -rf /var/www/mapnik-style/relief.tif /var/www/mapnik-style/hillshade.tif 
}
drop_db () {
    echo "Dropping database"
    cd /var/www
    setuser postgres drop_db gis
}

cli () {
    echo "Running bash"
    cd /var/www
    exec bash
}

start_services () {
    _startservice renderd
    _startservice apache2
}
stop_services (){
	_stopservice renderd
	_stopservice apache2
}
restart_services(){
	stop_services
	start_services
}

help () {
    cat /usr/local/share/doc/run/help.txt
}

_wait () {
    WAIT=$1
    NOW=`date +%s`
    BOOT_TIME=`stat -c %X /etc/container_environment.sh`
    UPTIME=`expr $NOW - $BOOT_TIME`
    DELTA=`expr 5 - $UPTIME`
    if [ $DELTA -gt 0 ]
    then
	sleep $DELTA
    fi
}

# Unless there is a terminal attached wait until 5 seconds after boot
# when runit will have started supervising the services.
if ! tty --silent
then
    _wait 5
fi

# Execute the specified command sequence
for arg 
do
    $arg;
done

# Unless there is a terminal attached don't exit, otherwise docker
# will also exit
if ! tty --silent
then
    # Wait forever (see
    # http://unix.stackexchange.com/questions/42901/how-to-do-nothing-forever-in-an-elegant-way).
    tail -f /dev/null
fi
