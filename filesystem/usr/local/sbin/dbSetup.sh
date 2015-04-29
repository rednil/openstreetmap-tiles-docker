#!/bin/sh

mkdir -p /var/www/milestones
milestonefile="/var/www/milestones/dbSetup"

if [ ! -f "$milestonefile" ] && [ -f /var/www/*.pbf ]; then
	echo "Setting up POSTGRES DB"
	deleteDb.sh
	initDb.sh 
	service postgresql start
	setuser postgres createuser -s www-data
	createDb.sh
	importOsm.sh
	createContours.sh
	# Stop the service so it can be managed by runit
	service postgresql stop 
	touch $milestonefile
fi
