#!/bin/sh

dbname=gis
asweb="setuser www-data"

echo "Creating database $dbname"
cd /var/www

# Create the database
setuser postgres createdb -O www-data $dbname

# Install the Postgis schema
$asweb psql -d $dbname -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql
#Install the spatial_ref_sys table
$asweb psql -d $dbname -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql

# Set the correct table ownership
$asweb psql -d $dbname -c 'ALTER TABLE geometry_columns OWNER TO "www-data"; ALTER TABLE spatial_ref_sys OWNER TO "www-data";'

# Add the 900913 Spatial Reference System
$asweb psql -d $dbname -f /usr/local/share/osm2pgsql/900913.sql

