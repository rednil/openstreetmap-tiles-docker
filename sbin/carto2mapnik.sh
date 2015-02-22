#!/bin/sh
styledir=/var/www/mapnik-style
echo "Translating project.yaml to osm.xml in $styledir"
$styledir/scripts/yaml2mml.py <$styledir/project.yaml >$styledir/project.mml
carto $styledir/project.mml >$styledir/osm.xml


