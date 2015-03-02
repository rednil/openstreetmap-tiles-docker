#!/bin/sh

imported_something=false
for f in /var/www/*.pbf
do
    if [ -f "$f" ]; then
		echo "Importing ${import} into gis"
		echo "$OSM_IMPORT_CACHE" | grep -P '^[0-9]+$' || \
			die "Unexpected cache type: expected an integer but found: ${OSM_IMPORT_CACHE}"
		number_processes=`nproc`;
		if test $number_processes -ge 8; then # Limit to 8 to prevent overwhelming pg with connections
				number_processes=8;
		fi
		setuser www-data osm2pgsql --slim --cache $OSM_IMPORT_CACHE --database gis --number-processes $number_processes $f
		imported_something=true
    fi
done
test $imported_something || echo "No OSM data imported. Place *.osm or *.pbf files into data directory in order to import."

