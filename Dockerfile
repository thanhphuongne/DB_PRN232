# Minimal Dockerfile for PostgreSQL
# This extends the official Postgres image and copies any init scripts
# placed in the local `initdb/` directory into the image so they run on
# first initialization. If you don't need custom init scripts you can
# skip building this and use the official image directly.
FROM postgres:15-alpine

# Keep database files under PGDATA and use a dedicated subdirectory
ENV PGDATA=/var/lib/postgresql/data/pgdata

# Copy initialization scripts (optional). Files placed in ./initdb/
# will be executed by the official entrypoint on first container start.
COPY ./initdb/ /docker-entrypoint-initdb.d/

VOLUME ["/var/lib/postgresql/data"]
EXPOSE 5432

# Default entrypoint and command are inherited from the postgres base image