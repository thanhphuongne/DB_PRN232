#!/bin/bash
set -e

# init-user-db.sh
# This script runs during the official postgres docker-entrypoint initialization.
# It creates an application database and user if APP_DB_NAME, APP_DB_USER and APP_DB_PASSWORD
# environment variables are provided when the container is first initialized.

# Required: POSTGRES_USER must exist (provided by the image or env)
if [ -z "$POSTGRES_USER" ]; then
  echo "POSTGRES_USER not set - aborting init script"
  exit 1
fi

# If APP_DB_* are set, create them (idempotent on fresh DB)
if [ -n "$APP_DB_NAME" ] && [ -n "$APP_DB_USER" ] && [ -n "$APP_DB_PASSWORD" ]; then
  echo "Creating application DB '$APP_DB_NAME' and user '$APP_DB_USER'"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    DO
    \
    BEGIN
      IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$APP_DB_USER') THEN
        CREATE USER "$APP_DB_USER" WITH PASSWORD '$APP_DB_PASSWORD';
      END IF;
    END
    ;
    EOSQL

  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE "$APP_DB_NAME";
    GRANT ALL PRIVILEGES ON DATABASE "$APP_DB_NAME" TO "$APP_DB_USER";
EOSQL
else
  echo "APP_DB_NAME, APP_DB_USER or APP_DB_PASSWORD not set. Skipping app DB/user creation."
fi

# End of init script
