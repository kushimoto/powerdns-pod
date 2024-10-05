#!/bin/bash

mkdir -p ./data/powerdns-{auth,admin}
touch ./data/powerdns-admin/admin.sqlite
sqlite3 ./data/powerdns-auth/pdns.sqlite < ./pdns.schema.sql
chown -R 953:953 ./data/powerdns-auth
chown -R 100:101 ./data/powerdns-admin
