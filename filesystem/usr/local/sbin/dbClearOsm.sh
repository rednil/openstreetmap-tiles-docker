db_user="www-data"
db_name=gis

for table in line nodes point polygon rels roads ways
do
	setuser $db_user psql -d $db_name -c "TRUNCATE planet_osm_${table};"
done; 
