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
    sv start $1 || die "Could not start $1"
}
_stopservice (){
	sv stop $1 || die "Could not stop $1"
}
startdb () {
    _startservice postgresql
}
testcontours (){
	_import_contours "append" 
}
initdb () {
    echo "Initialising postgresql"
    if [ -d /data/postgresql/9.3/main ] && [ $( ls -A /data/postgresql/9.3/main | wc -c ) -ge 0 ]
    then
        die "Initialisation failed: the directory is not empty: /data/postgresql/9.3/main"
    fi

    mkdir -p /data/postgresql/9.3/main && chown -R postgres /data/postgresql/
    sudo -u postgres -i /usr/lib/postgresql/9.3/bin/initdb --pgdata /data/postgresql/9.3/main
    ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /data/postgresql/9.3/main/server.crt
    ln -s /etc/ssl/private/ssl-cert-snakeoil.key /data/postgresql/9.3/main/server.key
}

createuser () {
    USER=www-data
    echo "Creating user $USER"
    setuser postgres createuser -s $USER
}

createdb () {
    dbname=gis
    echo "Creating database $dbname"
    cd /var/www

    # Create the database
    setuser postgres createdb -O www-data $dbname

    # Install the Postgis schema
    $asweb psql -d $dbname -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql

    # Set the correct table ownership
    $asweb psql -d $dbname -c 'ALTER TABLE geometry_columns OWNER TO "www-data"; ALTER TABLE spatial_ref_sys OWNER TO "www-data";'

    # Add the 900913 Spatial Reference System
    $asweb psql -d $dbname -f /usr/local/share/osm2pgsql/900913.sql
}
fromscratch (){
	#_stopservice postgresql would do a smart shutdown, which most times doesn't succeed
	/etc/init.d/postgresql stop
	rm -rf /data/postgresql
	dropdem
	initdb
	startdb
	createuser
	createdb
	import
	clear_cache
	startservices
}
redo_fromscratch () {
	mv /data/imported/* /data/
	fromscratch
}
import (){	
	import_osm
	import_dem
}
import_osm (){
	startdb
	imported_something=false
	for f in /data/*.osm
	do
	    if [ -f "$f" ]; then
		mkdir -p /data/imported
		echo "Importing ${import} into gis"
    		echo "$OSM_IMPORT_CACHE" | grep -P '^[0-9]+$' || \
        		die "Unexpected cache type: expected an integer but found: ${OSM_IMPORT_CACHE}"
    		number_processes=`nproc`;
    		if test $number_processes -ge 8; then # Limit to 8 to prevent overwhelming pg with connections
        		number_processes=8;
    		fi
    		$asweb osm2pgsql --slim --cache $OSM_IMPORT_CACHE --database gis --number-processes $number_processes $f
		mv $f /data/imported
		imported_something=true
	    fi
	done
 	test !$imported_something && echo "No OSM data imported. Place *.osm or *.pbf files into data directory in order to import."
}
import_dem (){
	import_contours
	import_relief
}
import_contours (){
	startdb
	mkdir -p /data/tmp	
	imported_something=false
	for f in /data/*.hgt
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
 	test !$imported_something && echo "No DEM data imported. Place *.hgt files into data directory in order to import."
	_dem_to_imported
}
reimport_contours (){
	startdb
	drop_contours
	_dem_from_imported
	import_contours
	_dem_to_imported
	clear_cache
}
_import_styles (){
	awk 'NR==FNR{a[$1]=$2;next}{ for (i in a) gsub(i,a[i])}1' /data/zoom-to-scale.txt /data/layer-contours.xml.inc >/usr/local/src/mapnik-style/inc/layer-contours.xml.inc
}        
import_relief (){
	drop_relief
        _dem_from_imported
	mkdir -p /data/tiff
	mkdir -p /data/tmp
	rm -rf /data/tmp/merged.tif
	rm -rf /data/tmp/warped.tif
	gdal_merge.py -v -o /data/tmp/merged.tif /data/*.hgt
        gdalwarp -of GTiff -co "TILED=YES" -srcnodata 32767 -t_srs "+proj=merc +ellps=sphere +R=6378137 +a=6378137 +units=m" -rcs -order 3 -tr 30 30 -multi /data/tmp/merged.tif /data/tmp/warped.tif
	gdaldem hillshade /data/tmp/warped.tif /data/tiff/hillshade.tif -z 2
	gdaldem color-relief /data/tmp/warped.tif /usr/local/src/mapnik-style/relief-colors.txt /data/tiff/relief.tif
	rm -rf /data/tmp/merged.tif
        rm -rf /data/tmp/warped.tif
	_dem_to_imported
}
_dem_to_imported (){
	mkdir -p /data/imported
	mv /data/*.hgt /data/imported/
}
_dem_from_imported (){
	mv /data/imported/*.hgt /data/
}
reimport_relief (){
	import_relief
	clear_cache	
}
clear_cache (){
	sv stop renderd
	rm -rf /var/lib/mod_tile/default
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
	rm -rf /data/tiff 
}
dropdb () {
    echo "Dropping database"
    cd /var/www
    setuser postgres dropdb gis
}

cli () {
    echo "Running bash"
    cd /var/www
    exec bash
}

startservices () {
    _startservice renderd
    _startservice apache2
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
