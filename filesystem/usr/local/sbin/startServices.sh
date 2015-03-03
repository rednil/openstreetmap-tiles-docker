#!/bin/sh

preflight.sh

service postgresql start
service renderd start
service apache2 start

