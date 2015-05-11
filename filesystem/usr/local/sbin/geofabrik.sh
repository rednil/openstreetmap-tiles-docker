#!/bin/bash

milestonefile="/var/www/milestones/geofabrik"

if [ -n "$region" ] && [ ! -f "$milestonefile" ]; then
	mkdir -p /var/www/milestones
	mkdir -p /var/www/geofabrik
	cd /var/www/geofabrik
	wget -x -N -nH http://download.geofabrik.de/${region}-latest.osm.pbf
	wget -x -N -nH http://download.geofabrik.de/${region}.poly
	ln -s /var/www/geofabrik/${region}-latest.osm.pbf /var/www/osm.pbf
	polyToGeojson.js ${region}.poly
	touch $milestonefile
fi


