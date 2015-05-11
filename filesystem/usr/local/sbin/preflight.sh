#!/bin/bash

set -e

# workaround for aufs bug from
# https://github.com/docker/docker/issues/783#issuecomment-56013588
mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private

mkdir -p /var/www/log

if [ ! -d "/var/www/html" ]; then
	echo "Copying html from /usr/local/src to /var/www"
	cp -r /usr/local/src/html /var/www
fi

echo "Creating directories required by the renderef (/var/www/mod_tile, /var/run/renderd)"
mkdir -p /var/www/mod_tile
mkdir -p /var/run/renderd
chown -R www-data.www-data /var/www/mod_tile /var/www/html /var/www/log /var/run/renderd

if [ -z "$region" ] && [ ! -f /var/www/*.pbf ] && [ -f /var/www/milestones/dbSetup ]; then
	echo "You provided neither a region as environmental variable nor a *.pbf file in /var/www/. Disabling services in /etc/service/"
	exit 1
fi
