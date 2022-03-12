#!/usr/bin/env bash

echo "### start-minio.sh"
set -x #echo on

MINIO_ROOT_USER=${1-"admin"}
MINIO_ROOT_PASSWORD=${2-"ChangeMe!"}
DATA_PATH=${3-"/data/minio"}
DOCKER_IMAGE=${4-"minio/minio:latest"}
CACHE_PATH=${5-"/vagrant/docker"}

load-docker-image.sh "${DOCKER_IMAGE}" "${CACHE_PATH}"

docker stop minio && docker rm minio

docker run \
  --detach --restart unless-stopped \
  --name minio \
  --hostname minio \
  --publish 80:80 \
  --publish 9000:9000 \
  --env "MINIO_ROOT_USER=${MINIO_ROOT_USER}" \
  --env "MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}" \
  --volume "${DATA_PATH}:/data:rw" \
  --volume /etc/timezone:/etc/timezone:ro \
  --volume /etc/localtime:/etc/localtime:ro \
  "${DOCKER_IMAGE}" \
    server --address "0.0.0.0:9000" --console-address "0.0.0.0:80" /data

save-docker-image.sh "${DOCKER_IMAGE}" "${CACHE_PATH}"
