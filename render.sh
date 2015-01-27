#!/bin/bash

if [ "$1" = "nepal" ]
then
	left=80;
	bottom=26;
	right=88;
	top=30;
else
	left=83.4;
	bottom=28;
	right=85;
	top=29;
fi

# from http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Bourne_shell_with_Awk
long2xtile()  
{ 
 long=$1
 zoom=$2
 echo "${long} ${zoom}" | awk '{ xtile = ($1 + 180.0) / 360 * 2.0^$2; 
  xtile+=xtile<0?-0.5:0.5;
  printf("%d", xtile ) }'
}
lat2ytile() 
{ 
 lat=$1;
 zoom=$2;
 tms=$3;
 ytile=`echo "${lat} ${zoom}" | awk -v PI=3.14159265358979323846 '{ 
   tan_x=sin($1 * PI / 180.0)/cos($1 * PI / 180.0);
   ytile = (1 - log(tan_x + 1/cos($1 * PI/ 180))/PI)/2 * 2.0^$2; 
   ytile+=ytile<0?-0.5:0.5;
   printf("%d", ytile ) }'`;
 if [ ! -z "${tms}" ]
 then
  #  from oms_numbering into tms_numbering
  ytile=`echo "${ytile}" ${zoom} | awk '{printf("%d\n",((2.0^$2)-1)-$1)}'`;
 fi
 echo "${ytile}";
}

for zoom in {0..18}
do
	xmin=$(long2xtile $left $zoom)
	xmax=$(long2xtile $right $zoom)
	ymax=$(lat2ytile $bottom $zoom)
	ymin=$(lat2ytile $top $zoom)
	echo "render_list -a -n 4 -t /data/mod_tile -x $xmin -X $xmax -y $ymin -Y $ymax -z $zoom -Z $zoom"
done
