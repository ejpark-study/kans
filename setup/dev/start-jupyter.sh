#!/usr/bin/env bash

echo "### start-jupyter.sh"
set -x #echo on

DOCKER_IMAGE=${1-"harbor.mlops/library/jupyter:slim"}
VOLUME_MOUNT=${2-"/share:/home/jupyter/workspace"}

docker stop jupyter && docker rm jupyter

docker run \
  --detach --restart unless-stopped \
  --user="1000:1000" \
  --name jupyter \
  --hostname jupyter \
  --network host \
  --volume "${VOLUME_MOUNT}" \
  --volume "/var/run/docker.sock:/var/run/docker.sock" \
  "${DOCKER_IMAGE}"
