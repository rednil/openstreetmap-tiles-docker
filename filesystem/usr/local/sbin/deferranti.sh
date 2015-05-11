#!/bin/bash
source /usr/local/sbin/env.sh

milestoneFile="$milestoneDir/deferranti"

if [ -f "$regionFile" ] && [ ! -f "$milestoneFile" ]; then
	deferranti.js
	touch $milestoneFile
fi


