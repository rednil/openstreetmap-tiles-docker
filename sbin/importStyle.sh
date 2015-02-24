styledir=/var/www/mapnik-style
if [ ! -d "$styledir" ]; then
	echo "Copying /usr/local/src/mapnik/style to $styledir"
	cp -r /usr/local/src/mapnik-style $styledir
	chown -R www-data.www-data $styledir
fi
if [ ! -d "$styledir/data" ]; then
	echo "Executing $styledir/.get-shapefiles.sh"
	cd $styledir
	setuser www-data $styledir/get-shapefiles.sh
	rm $styledir/data/*.zip $styledir/data/*.tgz
	cd /var/www
fi
if [ ! -f "$styledir/osm.xml" ]; then
	carto2mapnik.sh
fi
