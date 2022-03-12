#!/usr/bin/env bash

echo "### start-elk-proxy.sh"
set -x #echo on

DOCKER_IMAGE=${1-"harbor.mlops/library/elk-proxy:7.17.0"}
CACHE_PATH=${2-"/vagrant/docker"}

load-docker-image.sh "${DOCKER_IMAGE}" "${CACHE_PATH}"

docker stop elk-proxy && docker rm elk-proxy

docker run \
  --detach --restart=unless-stopped \
  --name elk-proxy \
  --hostname elk-proxy \
  --network host \
  "${DOCKER_IMAGE}"
