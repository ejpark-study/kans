#!/usr/bin/env bash

echo "### save-docker-image.sh"
set -x #echo on

DOCKER_IMAGE=${1-"gitlab/gitlab-ce:14.7.3-ce.0"}
CACHE_PATH=${2-"/vagrant/docker"}

tag_name=$(echo "${DOCKER_IMAGE}" | perl -ple 's#[/:]#_#g;')
filename="${CACHE_PATH}/${tag_name}.tar.gz"

if [[ ! -f "${filename}" ]]; then
  echo "${DOCKER_IMAGE}" \
    | perl -nle '$image=$_; s#[/:]#_#g; print "docker save $image | gzip - > '"${filename}"'"' \
    | bash -
fi