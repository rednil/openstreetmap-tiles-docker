#!/bin/sh

mkdir -p /var/www/milestones
milestonefile="/var/www/milestones/geofabrik"
cd /var/www

if [ -n "$region" ] && [ ! -f "$milestonefile" ]; then
	wget -x -N -nH http://download.geofabrik.de/${region}-latest.osm.pbf
	wget -x -N -nH http://download.geofabrik.de/${region}.poly
	touch $milestonefile
fi


