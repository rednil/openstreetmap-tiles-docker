#!/usr/bin/node

var fs = require('fs');

function poly2geojson(poly, name){
	return {
		"type": "Feature",
		"properties": {
			"name": name
		},
		"geometry": {
			"type": "LineString",
			"coordinates": poly
		}
	};
}

fs.readFile(process.argv[2], 'utf8', function(err, data){
	if(err){
		console.log(err);
	}
	else{
		var lineArr = data.split(/\n/);
		var poly = [];
		lineArr.forEach(function(line){
			var match = line.match(/^\s+([0-9.E+-]+)\s+([0-9.E+-]+)\s*$/);
			if(match){
				poly.push([Number(match[1]), Number(match[2])]);
			}
		});
		var jsonp = 'osmpoly='+JSON.stringify(poly2geojson(poly, process.argv[2]));
		fs.writeFile('/var/www/region.js', jsonp, function(err){
			if(err){
				console.log(err);
			}
			else{
				console.log('Saved polygon as a jsonp file');
			}
		});
	}
});

