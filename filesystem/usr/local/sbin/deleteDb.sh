#!/bin/bash

echo "Clearing Database"

if [ -d "/var/www/postgresql" ]; then
	echo "Stopping postgresql and deleting database directory"
	/etc/init.d/postgresql stop
	rm -rf /var/www/postgresql
else
	echo "No database directory, nothing to clean up"
fi

rm -rf /var/www/milestones/dbSetup
