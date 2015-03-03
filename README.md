# Mapnik Tile Server Container for Topographic Maps

This repository contains instructions for building a
[Docker](https://www.docker.io/) image containing the OpenStreetMap tile
serving software stack, including [contours and a colored relief](http://wiki.openstreetmap.org/wiki/HikingBikingMaps) from digital elevation mode (DEM) data. It started as a fork of [geo-data/openstreetmap-tiles-docker](https://github.com/geo-data/openstreetmap-tiles-docker) which in turn is based on the
[Switch2OSM instructions](http://switch2osm.org/serving-tiles/manually-building-a-tile-server-14-04/).

Given solely the name of the desired region at runtime, the software contained in the docker container assembles a running tileserver for that region from scratch.

In particular, the following steps are taken:

* Download Openstreetmap data for the given region from [Geofabrik](http://www.geofabrik.de/)
* Download DEM data for the given region from [Jonathan de Ferranti](http://viewfinderpanoramas.org/dem3.html)
* Initialize and setup a postgres database and import the Openstreetmap data
* render contour lines from the DEM data
* render a colored relief layer from the DEM data
* render a hillshade layer from the DEM data
* configure mapnik and renderd to serve images made up from all of the above layers (relief, hillshade, contour lines, openstreetmap data)

# Quick Start

You have to provide 

* (-p) a port on your local host that will be mapped to port 80 in the container and can be used to access the tile server
* (-v) the absolute path to an empty working directory 
* (-e) the name of the region you want to serve, in the notation used in the download section at [Geofabrik](http://www.geofabrik.de/), e.g. "europe/isle-of-man". Be careful, big countries or even continents need LOTS of space and time to build. This image is only tested for single, small countries.

Instead of providing the name of the desired region, you can place *.pbf files for the Openstreetmap data and *.hgt files for the DEM data in the working directory manually. They should be picked up during startup.

The image contains a minimalistic webpage featuring a leaflet web app, initially centered to the region you provided.

# Example

sudo docker run -p 4242:80 -e 'region=europe/isle-of-man' -v /home/xxx/emptydir:/var/www rednil/topotileserver 

Browse to: http://localhost:4242

# Debugging

For debugging purposes, you can start the container with the options "-ti" and by appending "/bin/bash" at the end in order to start into an interactive shell. All important scripts are located under /usr/local/sbin and mostly undocumented. init.sh is called during build, the other scripts are called via the phusion image init procedure from links in "/etc/my_init.d". Please note that some of the scripts set flags in "/var/www/milestones" that prevent them from running again if you restart the container with the same working directory. If you want to debug the scripts manually, you have to remove the respective milestones. The files "render.js" and "export.js" are not called automatically, but provide means to prerender a given region or export tiles for given zoom level (work in progress).

# About

The container runs Ubuntu 14.04 (Trusty) and is based on the
[phusion/baseimage-docker](https://github.com/phusion/baseimage-docker).  It
includes:

* Postgresql 9.3
* Apache 2.2
* Renderd and mod_tile, installed from ppa:kakrueger/openstreetmap
