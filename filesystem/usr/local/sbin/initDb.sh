#!/bin/bash

if [ -d /var/www/postgresql/9.3/main ] && [ $( ls -A /var/www/postgresql/9.3/main | wc -c ) -ge 0 ]
then
    echo "Skipping postgres initialization: the directory /var/www/postgresql/9.3/main is not empty"
else
	echo "Initialising postgresql"
	mkdir -p /var/www/postgresql/9.3/main && chown -R postgres /var/www/postgresql/
	sudo -u postgres -i /usr/lib/postgresql/9.3/bin/initdb --pgdata /var/www/postgresql/9.3/main
	ln -sf /etc/ssl/certs/ssl-cert-snakeoil.pem /var/www/postgresql/9.3/main/server.crt
	ln -sf /etc/ssl/private/ssl-cert-snakeoil.key /var/www/postgresql/9.3/main/server.key
fi
