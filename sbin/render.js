#!/usr/local/bin/shjs

require('shelljs/global');
var argv = require('minimist')(process.argv.slice(2));


// from http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#ECMAScript_.28JavaScript.2FActionScript.2C_etc..29
function long2tile(lon,zoom) {
	return (Math.floor((lon+180)/360*Math.pow(2,zoom))); 
}
function lat2tile(lat,zoom) { 
	return (Math.floor((1-Math.log(Math.tan(lat*Math.PI/180) + 1/Math.cos(lat*Math.PI/180))/Math.PI)/2 *Math.pow(2,zoom))); 
}

for (var z = (argv.minzoom || 0); z <= (argv.maxzoom || 18); z++){
	var xmin = long2tile(argv.left, z);
	var xmax = long2tile(argv.right, z);
	var ymin = lat2tile(argv.top, z);
	var ymax = lat2tile(argv.bottom, z);
	var cmd = [
		"render_list -a -n 4",
		"-t", "/data/mod_tile",
		"-x", xmin,
		"-X", xmax,
		"-y", ymin,
		"-Y", ymax,
		"-z", z, 
		"-Z", z
	].join(" ");
	(argv.sim ? console.log : exec)(cmd);
}

	
