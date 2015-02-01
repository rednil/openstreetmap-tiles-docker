# Perform sed substitutions for `renderd.conf`
s/;socketname=/socketname=/
s/plugins_dir=\/usr\/lib\/mapnik\/input/plugins_dir=\/usr\/local\/lib\/mapnik\/input/
s/XML=.*/XML=\/var\/www\/mapnik-style\/osm.xml/
s/HOST=tile.openstreetmap.org/HOST=localhost/
s/\/var\/lib\/mod_tile/\/var\/www\/mod_tile/
