echo "Initialising postgresql"
if [ -d /var/www/postgresql/9.3/main ] && [ $( ls -A /var/www/postgresql/9.3/main | wc -c ) -ge 0 ]
then
    die "Initialisation failed: the directory is not empty: /var/www/postgresql/9.3/main"
fi
mkdir -p /var/www/postgresql/9.3/main && chown -R postgres /var/www/postgresql/
sudo -u postgres -i /usr/lib/postgresql/9.3/bin/initdb --pgdata /var/www/postgresql/9.3/main
ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem /var/www/postgresql/9.3/main/server.crt
ln -s /etc/ssl/private/ssl-cert-snakeoil.key /var/www/postgresql/9.3/main/server.key
