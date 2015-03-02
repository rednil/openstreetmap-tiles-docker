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
bzip2 \
fonts-droid \
fonts-khmeros \
fonts-sil-padauk \
fonts-sipa-arundina \
fonts-taml-tscu \
fonts-tibetan-machine \
gdal-bin \
git-core \
libmapnik2.2 \
libtool \
mapnik-utils \
munin \
munin-node \
npm \
osm2pgsql \
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
unzip \
wget

# Install node and some npm modules
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN npm install -g carto shelljs minimist bower point-in-polygon request unzip

# Install the Mapnik stylesheet
RUN cd /usr/local/src && git clone https://github.com/rednil/openstreetmap-carto.git mapnik-style
RUN cd /usr/local/src/mapnik-style && ./get-shapefiles.sh
RUN cd /usr/local/src/mapnik-style/data/ && rm *.zip *.tgz

COPY filesystem /

RUN /usr/local/sbin/init.sh

# Expose the webserver and database ports
EXPOSE 80 5432

# We need the volume for importing data from
VOLUME ["/var/www"]

# Set the osm2pgsql import cache size in MB. Used in `run import`.
ENV OSM_IMPORT_CACHE 800

ENTRYPOINT ["/sbin/my_init", "--", "/usr/local/sbin/run.sh"]

# Default to assembling a running server
CMD ["startup"]
