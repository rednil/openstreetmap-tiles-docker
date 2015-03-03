#!/bin/sh

milestonefile="/var/www/milestones/deferranti"

if [ -f "/var/www/region.js" ] && [ ! -f "$milestonefile" ]; then
	deferranti.js
	touch $milestonefile
fi


