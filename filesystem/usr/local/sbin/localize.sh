#!/bin/bash


if [ -n "${PREFERRED_LANGUAGE}" ]; then
	if [ -d "/var/www/localization" ] && [ ! -f "/var/www/localization/${PREFERRED_LANGUAGE}" ]; then
		echo "Changing localization not supported";
		exit 1
	fi
	cd /usr/share/osm2pgsql/osm2pgsql
	echo "Altering osm2pgsql style in order to include int_name tags"
	sed -i "/node,way\s*name\s*text.*$/anode,way  int_name  text  linear" default.style
	echo "Altering osm2pgsql style in order to include name:en tags"
	sed -i "/node,way\s*name\s*text.*$/anode,way  name:en  text  linear" default.style
	if [ "en" != "$PREFERRED_LANGUAGE" ]; then
		echo "Altering osm2pgsql style in order to include name:${PREFERRED_LANGUAGE} tags"
		sed -i "/node,way\s*name\s*text.*$/anode,way  name:${PREFERRED_LANGUAGE}  text  linear" default.style
	fi
	echo "Altering project.yaml in oder to prefer local placenames"
	cd /usr/local/src/mapnik-style
	cp project.yaml bak.prerun.project.yaml
	sed -ri \
		-f project.yaml.docker.localization.sed \
		-e "s/GET_LOCALIZED/get_localized_placename(name,\"name:${PREFERRED_LANGUAGE}\",int_name,\"name:en\",false)/g" \
		project.yaml
	mkdir -p /var/www/localization
	touch /var/www/localization/${PREFERRED_LANGUAGE}
fi

