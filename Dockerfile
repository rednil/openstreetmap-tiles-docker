## -*- docker-image-name: "homme/openstreetmap-tiles:latest" -*-

##
# The OpenStreetMap Tile Server
#
# This creates an image with containing the OpenStreetMap tile server stack as
# described at
# <http://switch2osm.org/serving-tiles/manually-building-a-tile-server-12-04/>.
#

FROM phusion/baseimage:0.9.16
MAINTAINER Christian Linder <rednil@onyown.de>

# Set the locale. This affects the encoding of the Postgresql template
# databases.
ENV LANG C.UTF-8
RUN update-locale LANG=C.UTF-8

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && apt-get upgrade -y && apt-get install -y \
apache2 \
apache2-dev \
autoconf \
build-essential \
bzip2 \
fonts-droid \
fonts-khmeros \
fonts-sil-padauk \
fonts-sipa-arundina \
fonts-taml-tscu \
fonts-tibetan-machine \
gdal-bin \
git-core \
libagg-dev \
libboost-dev \
libboost-filesystem-dev \
libboost-program-options-dev \
libboost-python-dev \
libboost-regex-dev \
libboost-system-dev \
libboost-thread-dev \
libbz2-dev \
libcairo-dev \
libcairomm-1.0-dev \
libfreetype6-dev \
libgdal-dev \
libgdal1-dev \
libgeos++-dev \
libgeos-dev \
libgeos-dev \
libicu-dev \
liblua5.2-dev \
libmapnik-dev \
libpng12-dev \
libpq-dev \
libproj-dev \
libprotobuf-c0-dev \
libtiff4-dev \
libtool \
libtool \
libxml2-dev \
mapnik-utils \
munin \
munin-node \
npm \
postgresql-9.3-postgis-2.1 \
postgresql-contrib \
postgresql-server-dev-9.3 \
protobuf-c-compiler \
python-gdal \
python-mapnik \
python-software-properties \
python-yaml \
software-properties-common \
subversion \
tar \
ttf-dejavu \
ttf-indic-fonts-core \
ttf-kannada-fonts \
ttf-tamil-fonts \
ttf-unifont \
ttf-unifont \
unzip \
wget 

# Install osm2pgsql
RUN cd /tmp && git clone git://github.com/openstreetmap/osm2pgsql.git 
RUN cd /tmp/osm2pgsql && \
    ./autogen.sh && \
    ./configure && \
    make && make install

# Install the Mapnik library
RUN cd /tmp && git clone git://github.com/mapnik/mapnik
RUN cd /tmp/mapnik && \
    git checkout 2.2.x && \
    python scons/scons.py configure INPUT_PLUGINS=all OPTIMIZATION=3 SYSTEM_FONTS=/usr/share/fonts/truetype/ && \
    python scons/scons.py && \
    python scons/scons.py install && \
    ldconfig

# Verify that Mapnik has been installed correctly
RUN python -c 'import mapnik'

# Install mod_tile and renderd
RUN cd /tmp && git clone git://github.com/openstreetmap/mod_tile.git
RUN cd /tmp/mod_tile && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    make install-mod_tile && \
    ldconfig

# Install node and some npm modules
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN npm install -g carto shelljs minimist bower point-in-polygon request unzip

# Install the Mapnik stylesheet
RUN cd /usr/local/src && git clone https://github.com/rednil/openstreetmap-carto.git mapnik-style
RUN cd /usr/local/src/mapnik-style && ./get-shapefiles.sh
RUN cd /usr/local/src/mapnik-style/data/ && rm *.zip *.tgz

# Configure renderd
COPY renderd.conf.sed /tmp/
RUN cd /usr/local/etc && sed --file /tmp/renderd.conf.sed --in-place renderd.conf

# Create the files required for the mod_tile system to run
RUN mkdir /var/run/renderd && chown www-data: /var/run/renderd
RUN mkdir /var/www/mod_tile && chown www-data /var/www/mod_tile

# Configure mod_tile
COPY mod_tile.load /etc/apache2/mods-available/
COPY mod_tile.conf /etc/apache2/mods-available/
RUN a2enmod mod_tile

# Ensure the webserver user can connect to the gis database
RUN sed -i -e 's/local   all             all                                     peer/local gis www-data peer/' /etc/postgresql/9.3/main/pg_hba.conf

# Tune postgresql
COPY postgresql.conf.sed /tmp/
RUN sed --file /tmp/postgresql.conf.sed --in-place /etc/postgresql/9.3/main/postgresql.conf

# Define the application logging logic
COPY syslog-ng.conf /etc/syslog-ng/conf.d/local.conf
RUN rm -rf /var/log/postgresql

# Create a `postgresql` `runit` service
COPY postgresql /etc/sv/postgresql
RUN update-service --add /etc/sv/postgresql

# Create an `apache2` `runit` service
COPY apache2 /etc/sv/apache2
RUN update-service --add /etc/sv/apache2

# Create a `renderd` `runit` service
COPY renderd /etc/sv/renderd
RUN update-service --add /etc/sv/renderd

RUN DEBIAN_FRONTEND=noninteractive apt-get remove -y \
apache2-dev \
autoconf \
build-essential \
git-core \
libagg-dev \
libboost-dev \
libboost-filesystem-dev \
libboost-program-options-dev \
libboost-python-dev \
libboost-regex-dev \
libboost-system-dev \
libboost-thread-dev \
libbz2-dev \
libcairo-dev \
libcairomm-1.0-dev \
libfreetype6-dev \
libgdal-dev \
libgdal1-dev \
libgeos++-dev \
libgeos-dev \
libgeos-dev \
libicu-dev \
liblua5.2-dev \
libmapnik-dev \
libpng12-dev \
libpq-dev \
libproj-dev \
libprotobuf-c0-dev \
libtiff4-dev \
libxml2-dev 

# Clean up APT when done
RUN apt-get autoremove -y && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose the webserver and database ports
EXPOSE 80 5432

# We need the volume for importing data from
VOLUME ["/var/www"]

# Set the osm2pgsql import cache size in MB. Used in `run import`.
ENV OSM_IMPORT_CACHE 800

# Add the README
COPY README.md /usr/local/share/doc/

# Add the entrypoint
COPY sbin/* /usr/local/sbin/

ENTRYPOINT ["/sbin/my_init", "--", "/usr/local/sbin/run.sh"]

# Add the webroot, will be copied to /var/www at runtime
COPY html /usr/local/src/html

# workaround for aufs bug from
# https://github.com/docker/docker/issues/783#issuecomment-56013588
RUN mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private

# Default to assembling a running server
CMD ["startup"]
