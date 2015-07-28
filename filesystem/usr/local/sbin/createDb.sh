#!/bin/bash

source /usr/local/sbin/env.sh

cd /var/www

echo "Creating database $dbname with owner $db_user"
setuser postgres createdb -O $db_user $db_name

echo "Installing the postgis schema"
setuser $db_user psql -q -d $db_name -f /usr/share/postgresql/9.3/contrib/postgis-2.1/postgis.sql

echo "Installing the spatial_ref_sys table"
setuser $db_user psql -q -d $db_name -f /usr/share/postgresql/9.3/contrib/postgis-2.1/spatial_ref_sys.sql

# Is this required? Probably not!
# setuser $db_user psql -q -d $db_name -c 'ALTER TABLE geometry_columns OWNER TO "www-data"; ALTER TABLE spatial_ref_sys OWNER TO "www-data";'


