styledir=/var/www/mapnik-style
if [ ! -d "$styledir" ]; then
	echo "Copying /usr/local/src/mapnik/style to $styledir"
	cp -r /usr/local/src/mapnik-style $styledir
	chown -R www-data.www-data $styledir
fi
if [ ! -d "$styledir/data" ]; then
	echo "Executing $styledir/.get-shapefiles.sh"
	setuser www-data ./get-shapefiles.sh
	rm data/*.zip data/*.tgz
	cd /var/www
fi
if [ ! -d "$styledir/osm.xml" ]; then
	carto2mapnik.sh
fi
