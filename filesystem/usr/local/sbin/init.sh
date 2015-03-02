# Verify that Mapnik has been installed correctly
python -c 'import mapnik'
# Create the files required for the mod_tile system to run
mkdir /var/run/renderd && chown www-data: /var/run/renderd
mkdir /var/www/mod_tile && chown www-data /var/www/mod_tile
# Configure renderd
cd /etc && sed --file /tmp/renderd.conf.sed --in-place renderd.conf
# Configure apache
cd /etc/apache2/sites-available && sed --file /tmp/tileserver_site.conf.sed --in-place tileserver_site.conf
# Ensure the webserver user can connect to the gis database
sed -i -e 's/local   all             all                                     peer/local gis www-data peer/' /etc/postgresql/9.3/main/pg_hba.conf
# Tune postgresql
sed --file /tmp/postgresql.conf.sed --in-place /etc/postgresql/9.3/main/postgresql.conf
# application logging logic is defined in /etc/syslog-ng/conf.d/local.conf
rm -rf /var/log/postgresql
# Create a `postgresql` `runit` service
update-service --add /etc/sv/postgresql
# Create an `apache2` `runit` service
update-service --add /etc/sv/apache2
# Create a `renderd` `runit` service
update-service --add /etc/sv/renderd
# workaround for aufs bug from
# https://github.com/docker/docker/issues/783#issuecomment-56013588
mkdir /etc/ssl/private-copy
mv /etc/ssl/private/* /etc/ssl/private-copy/
rm -r /etc/ssl/private
mv /etc/ssl/private-copy /etc/ssl/private
chmod -R 0700 /etc/ssl/private
chown -R postgres /etc/ssl/private

