i=20
for cmd in \
	checkForNewRegion.sh \
	preflight.sh \
	localize.sh \
	geofabrik.sh \
	deferranti.sh \
	dbSetup.sh \
	createContours.sh \
	importStyle.sh \
	createRelief.sh \
	createHillshade.sh
do
	ln -s /usr/local/sbin/${cmd} /etc/my_init.d/${i}_${cmd}
	i=$(( i + 5 ))
done
