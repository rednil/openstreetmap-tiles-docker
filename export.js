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

var zmin = argv.minzoom || 0;
var zmax = argv.maxzoom || 18; 

var z=zmin-1, x=0, y=0, xmax=-1, ymax=-1, xmin, ymin, n=0, done=false;

function forecast(){
	var n=0;
	for (var z = zmin; z <= (argv.maxzoom || 18); z++){
		n = n + (getXmax(z)-getXmin(z)+1) * (getYmax(z)-getYmin(z)+1);
	}
	return n;
}

var nmax = forecast();
var nfail = 0;
var threads = argv.threads || 4;

console.log("Downloading", nmax, "tiles using "+threads+" threads");

for(var i=0; i<threads; i++){
	getNext();
}

function getXmin(z){
	return long2tile(argv.left, z);
}
function getXmax(z){
	return long2tile(argv.right, z);
}
function getYmin(z){
	return lat2tile(argv.top, z);
}
function getYmax(z){
	return lat2tile(argv.bottom, z);
}
function fraction(n, min, max){
	return n+" ("+((n-min)+1)+"/"+((max-min)+1)+")";
}

var start = (new Date()).getTime();

function getNext(code, output){
	if((++y)>ymax){
		if((++x)>xmax){
			console.log();
			if((++z)>zmax){
				if(!done){
					console.log("Downloaded "+n+" tiles.");
					if(n<nmax){
						console.log((nmax-n)+" tiles missing.");
					}
					done=true;
				}
				return;
			}
			x=xmin=getXmin(z);
			xmax=getXmax(z);
		}
		y=ymin=getYmin(z);
		ymax=getYmax(z);
	}
	if(code){
		//console.log();
		//console.log(code, output, test);
		nfail++;
	}
	else{
		n=n+1;
	}
	var url = (argv.url||"http://localhost:8080/osm_tiles/")+z+"/"+x+"/"+y+".png";
	var cmd = "wget -q -x -nH " + url;
	if(!argv.quiet){
		var current = (new Date()).getTime();
		var sofar = current-start;
		var total = (nmax/n)*sofar;
		var eta = (new Date(start+total)).toTimeString().split(" ")[0];
		var progress = n+"/"+nmax+"("+Math.round(n/nmax*100)+"%, ETA: "+eta+"), failed: "+nfail+"("+(n?Math.round(nfail/n*10000)/100:100)+"%), z: "+fraction(z,zmin,zmax)+", x: "+fraction(x,xmin,xmax)+", y:"+fraction(y,ymin,ymax);
		process.stdout.write("\r"+progress);
	}
	if(argv.verbose){
		console.log();
		console.log(cmd);
	}
	if(argv.sim){
		setTimeout(getNext,1);
	}
	else{
		exec(cmd, {async:true}, getNext);
	}
}

			

