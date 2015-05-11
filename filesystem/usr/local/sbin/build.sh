#!/bin/sh

# insert contour, hillshade and relief snippets into project file
cd /usr/local/src/mapnik-style
cp project.yaml bak.prebuild.project.yaml
sed -ri -f project.yaml.docker.dem.sed project.yaml

# Verify that Mapnik has been installed correctly
python -c 'import mapnik'

# Configure renderd
cd /etc
sed -i -f /tmp/renderd.conf.sed renderd.conf

# Configure apache
cd /etc/apache2/sites-available
sed -i -f /tmp/tileserver_site.conf.sed tileserver_site.conf

# Ensure the webserver user can connect to the gis database
sed -i -e 's/local\s*all\s*all\s*peer/local gis www-data peer/' /etc/postgresql/9.3/main/pg_hba.conf

# Tune postgresql
sed -i -f /tmp/postgresql.conf.sed /etc/postgresql/9.3/main/postgresql.conf

# application logging logic is defined in /etc/syslog-ng/conf.d/local.conf
rm -rf /var/log/postgresql

# workaround for aufs bug from
# https://github.com/docker/docker/issues/783#issuecomment-56013588
mkdir /etc/ssl/private-copy
mv /etc/ssl/private/* /etc/ssl/private-copy/
rm -r /etc/ssl/private
mv /etc/ssl/private-copy /etc/ssl/private
chmod -R 0700 /etc/ssl/private
chown -R postgres /etc/ssl/private

createRunitLinks.sh
