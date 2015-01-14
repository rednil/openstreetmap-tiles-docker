# OpenStreetMap Tile Server Container

This repository contains instructions for building a
[Docker](https://www.docker.io/) image containing the OpenStreetMap tile
serving software stack, including [contours and a colored relief](http://wiki.openstreetmap.org/wiki/HikingBikingMaps) from elevation data. It is based on the
[Switch2OSM instructions](http://switch2osm.org/serving-tiles/manually-building-a-tile-server-14-04/).

As well as providing an easy way to set up and run the tile serving software it
also provides instructions for managing the back end database, allowing you to:

* Create the database
* Import OSM data into the database
* Drop the database

Run `docker run XXX` for usage instructions.

## About

The container runs Ubuntu 14.04 (Trusty) and is based on the
[phusion/baseimage-docker](https://github.com/phusion/baseimage-docker).  It
includes:

* Postgresql 9.3
* Apache 2.2
* The latest [Osm2pgsql](http://wiki.openstreetmap.org/wiki/Osm2pgsql) code (at
  the time of image creation)
* The latest [Mapnik](http://mapnik.org/) code (at the time of image creation)
* The latest [Mod_Tile](http://wiki.openstreetmap.org/wiki/Mod_tile) code (at
  the time of image creation)

## Issues

This is a work in progress, for a stable version see its [origin](https://github.com/geo-data/openstreetmap-tiles-docker) (without contours and color relief).
* When running the container using the "aufs" storage backend (default in Ubuntu 14.04), I ran into a [permission issue](https://github.com/geo-data/openstreetmap-tiles-docker/issues/3). I resolved it by switching to the devicemapper backend.
* I encountered difficulties building this container using the devicemapper driver and filed a [docker issue](https://github.com/docker/docker/issues/10089).

