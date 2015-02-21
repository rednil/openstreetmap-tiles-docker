#!/bin/sh

mkdir -p /var/www/milestones
milestonefile="/var/www/milestones/dbSetup"

if [ ! -f "$milestonefile" ]; then
	echo "Setting up POSTGRES DB"
	deleteDb.sh
	initDb.sh 
	sv start postgresql
	setuser postgres createuser -s www-data
	createDb.sh
	importOsm.sh
	touch $milestonefile
fi
