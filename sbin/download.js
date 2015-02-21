#!/usr/local/bin/shjs
require('shelljs/global');

var fs = require('fs');

var mainDir='/var/www';
var styleDir='/var/www/mapnik-style';

var request = require('request');
var argv = require('minimist')(process.argv.slice(2));
var unzip = require('unzip');
var files;
var osm = '/var/www/osm/';
var polyFilename = env.region+'.poly';
var pbfFilename =  env.region+'-latest.osm.pbf';

var inside = require('point-in-polygon');

var postgresDir = mainDir+'/postgresql';

mkdir('-p', osm+env.region);

ensureGeofabrik(polyFilename, poly);
ensureGeofabrik(pbfFilename, pbf);


function ensureGeofabrik(file, cb){
	if(test('-f', osm+file)){
		console.log('File', file, 'already present');
		cb(file);
	}
	else{
		var target = 'http://download.geofabrik.de/'+file;
		request(target)
		.pipe(fs.createWriteStream(osm+file))
		.on('close', function(){
			console.log('Downloaded file', file);
			cb(file);
		});
	}
}

function pbf(file){
	ln('-s', osm+file, '/var/www/osm.pbf');
}

function poly(file){
	fs.readFile(osm+file, 'utf8', function(err, data){
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
			files = getFileList(poly);
			console.log('The following files are required:');
			console.dir(files.deFerranti);
			deFerranti = files.deFerranti;
			for(var file in deFerranti){
				var dirname = 'deferranti/'+file;
				if(test('-d', dirname)){
					console.log('Directory',dirname,'already present');
					extract(file);
				}
				else{
					downloadDeFerranti(file);
				}
			}
		}
	});
}
function downloadDeFerranti(file){
	var target = 'http://www.viewfinderpanoramas.org/dem3/'+file+'.zip';
	request(target)
	.pipe(unzip.Extract({path:'deferranti'}))
	.on('close', function(){
		rm(file+'.zip');
		extract(file);
	});
}

function extract(folder){
	console.log('Creating symlinks for', folder);
	for(var file in files.deFerranti[folder]){
		var source = 'deferranti/'+folder+'/'+file;
		if(test('-f', source)){
			ln('-sf', source, file);
		}
	}
}

function getBB(poly){
	var bbox = {
		xmax: -360,
	    ymax: -360,
		xmin: 360,
		ymin: 360
	};
	
	poly.forEach(function(point){
		bbox.xmax = Math.max(bbox.xmax, point[0]);
		bbox.ymax = Math.max(bbox.ymax, point[1]);
		bbox.xmin = Math.min(bbox.xmin, point[0]);
		bbox.ymin = Math.min(bbox.ymin, point[1]);
	});
	return bbox;
}

function getFileList(poly){
	var bb = getBB(poly);
	console.log('Bounding Box:');
	console.dir(bb);
	var deFerranti = {};
	var hgtList = {};
	for(var x=Math.floor(bb.xmin); x<=Math.floor(bb.xmax); x++){
		for(var y=Math.floor(bb.ymin); y<=Math.floor(bb.ymax); y++){
			// check if one of the four corners of a given 
			// tile is inside the polygon
			var required = (
				inside([x,y], poly) ||
				inside([x,y+1], poly) ||
				inside([x+1,y], poly) ||
				inside([x+1,y+1], poly) 
			);
			console.log('checked', x, y, required);
			if(required){
				var zipName = getDeFerrantiName([x,y]);
				var fileName = coorToName([x,y]);
				if(!deFerranti[zipName]){
					deFerranti[zipName]={};
				}
				deFerranti[zipName][fileName]=true;
				hgtList[fileName]=true;
			}
		}
	}
	return({
		deFerranti: deFerranti,
		hgtFiles: hgtList
	});
}
function coorToName(coor){
	return (coor[1]>0?'N':'S')+pad(coor[1],2)+(coor[0]>0?'E':'W')+pad(coor[0],3)+'.hgt';
}
function pad(num, size) {
    var s = "00" + Math.abs(num);
    return s.substr(s.length-size);
}
function getDeFerrantiName(coor){
	var x=Math.floor(1+Math.floor(180+coor[0])/6);
	var y=String.fromCharCode(65+Math.floor(Math.abs(coor[1]/4)));
	return (coor[1]<0?'S':'')+y+x;
}
	
