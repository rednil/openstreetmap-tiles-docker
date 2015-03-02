#!/bin/sh

if [ ! -d "/var/www/html" ]; then
	echo "Copying html from /usr/local/src to /var/www"
	cp -r /usr/local/src/html /var/www
fi
if [ -f "/var/www/region.js" ]; then
	cp /var/www/region.js /var/www/html
fi
mkdir -p /var/www/mod_tile
chown -R www-data.www-data /var/www/mod_tile /var/www/html

sv start postgresql
sv start renderd
sv start apache2

