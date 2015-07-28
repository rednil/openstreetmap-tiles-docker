#!/bin/bash

milestonefile="/var/www/milestones/geofabrik"

if [ -n "$region" ] && [ ! -f "$milestonefile" ]; then
	mkdir -p /var/www/milestones
	mkdir -p /var/www/geofabrik
	cd /var/www/geofabrik
	echo "Downloading ${region}-latest.osm.pbf from geofabrik"
	wget -q -x -N -nH http://download.geofabrik.de/${region}-latest.osm.pbf
	echo "Downloading ${region}.poly from geofabrik"
	wget -q -x -N -nH http://download.geofabrik.de/${region}.poly
	ln -sf /var/www/geofabrik/${region}-latest.osm.pbf /var/www/osm.pbf
	polyToGeojson.js ${region}.poly
	touch $milestonefile
fi


