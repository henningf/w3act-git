#!/bin/sh

set -e

# Setting password for postgesdb
export PGPASSWORD="$POSTGRES_PASSWORD"


# Startup script, designed to wait for postgres to come up before w3act.
# W3ACT fails of postgres is not available

until psql -h "$POSTGRES_HOST" -d "$POSTGRES_DB" -U "$POSTGRES_USER" -c '\l'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "creating application.conf"
/opt/w3act/bin/create_config.py

>&2 echo "Postgres is up - executing command"
exec "/opt/w3act/bin/w3act" "-Dconfig.file=/opt/w3act/conf/prod.conf"
