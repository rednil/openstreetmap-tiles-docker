#!/usr/local/bin/shjs

var argv = require('minimist')(process.argv.slice(2));

// from http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#ECMAScript_.28JavaScript.2FActionScript.2C_etc..29
function long2tile(lon,zoom) {
	return (Math.floor((lon+180)/360*Math.pow(2,zoom))); 
}
function lat2tile(lat,zoom) { 
	return (Math.floor((1-Math.log(Math.tan(lat*Math.PI/180) + 1/Math.cos(lat*Math.PI/180))/Math.PI)/2 *Math.pow(2,zoom))); 
}

var zmin = argv.minzoom || 0;
var zmax = argv.maxzoom || 18;

for (var z = zmin; z <= zmax; z++){
	var xmin = long2tile(argv.left, z);
	var xmax = long2tile(argv.right, z);
	var ymin = lat2tile(argv.top, z);
	var ymax = lat2tile(argv.bottom, z);
	var cmdArr = [];
	if(argv.test){
		console.log("zoom:", z, ", xmin:", xmin, ", xmax:", xmax, ", ymin:", ymin, ", ymax:", ymax);
	}
	else{
		for(var x = xmin; x<=xmax; x++){
			for(var y = ymin; y<=ymax; y++){
				var url = "http://localhost:8080/osm_tiles/"+z+"/"+x+"/"+y+".png";
				var cmd = "wget -x -nH " + url;
				cmdArr.push(cmd);
				if( (y==ymax && x==xmax && z==zmax) || (cmdArr.length>=(argv.threads || 4))){
					(argv.sim ? console.log : exec)(cmdArr.join(" & "));
					cmdArr=[];
				}
			}
		}
	}
}


			

