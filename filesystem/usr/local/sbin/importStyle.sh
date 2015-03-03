#!/bin/sh

styledir=/var/www/mapnik-style
if [ ! -d "$styledir" ]; then
	echo "Copying /usr/local/src/mapnik/style to $styledir"
	cp -r /usr/local/src/mapnik-style $styledir
fi
if [ ! -d "$styledir/data" ]; then
	ln -s /etc/mapnik-osm-carto-data/data $styledir
fi
chown -R www-data.www-data $styledir
if [ ! -f "$styledir/osm.xml" ]; then
	carto2mapnik.sh
fi
