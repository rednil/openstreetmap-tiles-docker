i=10
for cmd in \
	preflight.sh \
	checkForNewRegion.sh \
	geofabrik.sh \
	deferranti.sh \
	dbSetup.sh \
	importStyle.sh \
	createContours.sh \
	createRelief.sh \
	createHillshade.sh
do
	ln -s /usr/local/sbin/${cmd} /etc/my_init.d/${i}_${cmd}
	i=$(( i + 10 ))
done
