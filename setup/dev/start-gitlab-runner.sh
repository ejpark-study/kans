#!/usr/bin/env bash

echo "### start-gitlab-runner.sh"
set -x #echo on

DOCKER_IMAGE=${1-"gitlab/gitlab-runner:latest"}
DATA_PATH=${2-"/data/gitlab-runner"}
CERTS_PATH=${3-"/data/gitlab/config/ssl"}
CACHE_PATH=${4-"/vagrant/docker"}

# make certs
mkdir -p "${DATA_PATH}/certs"
if [[ ! -f "${DATA_PATH}/config.toml" ]]; then
  touch "${DATA_PATH}/config.toml"
fi

cp "${CERTS_PATH}"/*.* "${DATA_PATH}/certs/"

# start docker
load-docker-image.sh "${DOCKER_IMAGE}" "${CACHE_PATH}"

docker stop gitlab-runner && docker rm gitlab-runner

docker run \
  --detach --restart unless-stopped \
  --name gitlab-runner \
  --hostname gitlab-runner \
  --privileged \
  --network host \
  --env "GIT_SSL_NO_VERIFY=1" \
  --volume "${DATA_PATH}:/etc/gitlab-runner" \
  --volume "/var/run/docker.sock:/var/run/docker.sock" \
  "${DOCKER_IMAGE}"

save-docker-image.sh "${DOCKER_IMAGE}" "${CACHE_PATH}"
