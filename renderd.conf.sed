# Perform sed substitutions for `renderd.conf`
s/;socketname=/socketname=/
s/plugins_dir=\/usr\/lib\/mapnik\/input/plugins_dir=\/usr\/local\/lib\/mapnik\/input/
s/XML=.*/XML=\/usr\/local\/src\/mapnik-style\/osm.xml/
s/HOST=tile.openstreetmap.org/HOST=localhost/
s/\/var\/lib\/mod_tile/\/data\/mod_tile/
