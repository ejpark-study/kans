#!/usr/bin/env bash

echo "### start-postgres.sh"
set -x #echo on

POSTGRES_PASSWORD=${1-"ChangeMe!"}
DATA_PATH=${2-"/data/postgres"}
DOCKER_IMAGE=${3-"postgres:14-bullseye"}
CACHE_PATH=${4-"/vagrant/docker"}

load-docker-image.sh "${DOCKER_IMAGE}" "${CACHE_PATH}"

docker stop postgres && docker rm postgres

docker run \
  --detach --restart unless-stopped \
  --name postgres \
  --hostname postgres \
  --network host \
  --env "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}" \
  --env "PGDATA=/var/lib/postgresql/data/pgdata" \
  --volume "${DATA_PATH}:/var/lib/postgresql/data" \
  --volume /etc/timezone:/etc/timezone:ro \
  --volume /etc/localtime:/etc/localtime:ro \
  "${DOCKER_IMAGE}"

save-docker-image.sh "${DOCKER_IMAGE}" "${CACHE_PATH}"

# choco install dbeaver
