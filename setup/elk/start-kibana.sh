#!/usr/bin/env bash

echo "### start-kibana.sh"
set -x #echo on

CONTAINER_NAME=${1-"kibana"}
ELASTICSEARCH_USERNAME=${2-"kibana_system"}
ELASTICSEARCH_PASSWORD=${3-"ChangeMe!"}
ELASTICSEARCH_HOSTS=${4-"https://elk.mlops:9200"}
DOCKER_IMAGE=${5-"harbor.mlops/library/kibana:7.17.0"}
CACHE_PATH=${6-"/vagrant/docker"}

load-docker-image.sh "${DOCKER_IMAGE}" "${CACHE_PATH}"

docker stop "${CONTAINER_NAME}" && docker rm "${CONTAINER_NAME}"

docker run \
  --detach --restart=unless-stopped \
  --name "${CONTAINER_NAME}" \
  --hostname "${CONTAINER_NAME}" \
  --network host \
  --env "SERVER_HOST=0.0.0.0" \
  --env "ELASTICSEARCH_HOSTS=${ELASTICSEARCH_HOSTS}" \
  --env "ELASTICSEARCH_USERNAME=${ELASTICSEARCH_USERNAME}" \
  --env "ELASTICSEARCH_PASSWORD=${ELASTICSEARCH_PASSWORD}" \
  --env "MONITORING_ENABLED=true" \
  --env "NODE_OPTIONS=--max-old-space-size=1800" \
  --env "ELASTICSEARCH_SSL_ENABLED=true" \
  --env "ELASTICSEARCH_SSL_VERIFICATIONMODE=certificate" \
  --env "ELASTICSEARCH_SSL_KEYSTORE_PATH=/usr/share/kibana/config/elasticsearchcerts/elastic-certificates.p12" \
  --env "ELASTICSEARCH_SSL_KEYSTORE_PASSWORD=\"\"" \
  --env "SERVER_SSL_ENABLED=true" \
  --env "SERVER_SSL_KEYSTORE_PATH=/usr/share/kibana/config/elasticsearchcerts/elastic-certificates.p12" \
  --env "SERVER_SSL_KEYSTORE_PASSWORD=\"\"" \
  "${DOCKER_IMAGE}"
