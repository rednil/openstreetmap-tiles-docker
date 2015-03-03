#!/bin/sh

mkdir -p /var/www/log
if [ ! -d "/var/www/html" ]; then
	echo "Copying html from /usr/local/src to /var/www"
	cp -r /usr/local/src/html /var/www
fi
if [ -f "/var/www/region.js" ]; then
	cp /var/www/region.js /var/www/html
fi
mkdir -p /var/www/mod_tile
chown -R www-data.www-data /var/www/mod_tile /var/www/html /var/www/log

if [ -z "$region" ] && [ ! -f /var/www/*.pbf ] && [ -f /var/www/milestones/dbSetup ]; then
	echo "You provided neither a region as environmental variable nor a *.pbf file in /var/www/. Disabling services in /etc/service/"
	cd /etc/service
	touch apache2/down
	touch renderd/down
	touch postgresql/down
fi
