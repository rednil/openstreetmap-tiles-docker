#!/bin/bash

source /usr/local/sbin/env.sh

echo "Creating database $dbname"
cd /var/www

# Create the database
setuser postgres createdb -O $db_user $db_name

# Install the Postgis schema
setuser $db_user psql -d $db_name -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql
#Install the spatial_ref_sys table
setuser $db_user psql -d $db_name -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql

# Set the correct table ownership
setuser $db_user psql -d $db_name -c 'ALTER TABLE geometry_columns OWNER TO "www-data"; ALTER TABLE spatial_ref_sys OWNER TO "www-data";'

# Add the 900913 Spatial Reference System
setuser $db_user psql -d $db_name -f /usr/local/share/osm2pgsql/900913.sql

