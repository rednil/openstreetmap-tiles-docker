#!/bin/sh

cd /var/www

if [ -n "$region" ]; then
	checkForNewRegion.sh
	download.js
	dbSetup.sh
	importStyle.sh
	createContours.sh
	createRelief.sh
	createHillshade.sh
else
	echo "You didn't provide a region"
fi

