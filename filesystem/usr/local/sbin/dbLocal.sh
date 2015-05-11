#!/bin/bash

source /usr/local/sbin/env.sh

echo "Adding function transliterate to database $db_name"
setuser $db_user psql -d $db_name -c "CREATE FUNCTION transliterate(text)RETURNS text AS '/usr/lib/postgresql/9.3/lib/utf8translit', 'transliterate' LANGUAGE C STRICT;"

echo "Adding function get_localized_placename to  database $db_name"
setuser $db_user psql -f /usr/local/src/get_localized_name.sql $db_name

