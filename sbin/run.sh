#!/bin/sh

startup (){
	if [ ! -d /var/www/region/$region ]; then
		deleteDb.sh
		rm -rf \
			/var/www/milestones \
			/var/www/tmp \
			/var/www/*.pbf \
			/var/www/*.hgt \
			/var/www/mapnik-style/hillshade*.tif \
			/var/www/mapnik-style/relief*.tif \
			/var/www/mapnik-style/contours

		setuser www-data mkdir -p /var/www/region/$region
	fi

	download.js
	dbSetup.sh
	createContours.sh
	createRelief.sh
	createHillshade.sh
	importStyle.sh
	sv start renderd
	sv start apache2
}

cli () {
    echo "Running bash"
    cd /var/www
    exec bash
}

# Execute the specified command sequence
for arg 
do
    $arg;
done

# Unless there is a terminal attached don't exit, otherwise docker
# will also exit
if ! tty --silent
then
    # Wait forever (see
    # http://unix.stackexchange.com/questions/42901/how-to-do-nothing-forever-in-an-elegant-way).
    tail -f /dev/null
fi


