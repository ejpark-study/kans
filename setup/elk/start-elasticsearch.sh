#!/usr/bin/env bash

echo "### start-elasticsearch.sh"
set -x #echo on

NODE_NAME=${1-"elasticsearch1.mlops"}
ELASTIC_PASSWORD=${2-"ChangeMe!"}
DATA_PATH=${3-"/data/elasticsearch"}
CLS_NAME=${4-"mlops"}
DOCKER_IMAGE=${5-"harbor.mlops/library/elasticsearch:7.17.0"}
MAX_MEMORY=${6-"4g"}
SEED_HOSTS=${7-"192.168.56.22,192.168.56.23,192.168.56.24"}
CACHE_PATH=${8-"/vagrant/docker"}

NETWORK_HOST=$(tac /etc/hosts | grep "${NODE_NAME}" | head -n1 | cut -f1)

CONTAINER_NAME="elasticsearch"
ELASTIC_USERNAME="elastic"
ES_JAVA_OPTS="-Xms${MAX_MEMORY} -Xmx${MAX_MEMORY}"
WHITELIST="elk.mlops:9200"

load-docker-image.sh "${DOCKER_IMAGE}" "${CACHE_PATH}"

swapoff -a
echo vm.max_map_count=262144 | tee -a /etc/sysctl.conf
sysctl --system

if [[ ! -d "${DATA_PATH}" ]]; then
  mkdir -p "${DATA_PATH}"
fi

docker stop "${CONTAINER_NAME}" && docker rm "${CONTAINER_NAME}"

docker run \
  --detach --restart=unless-stopped \
  --privileged \
  --network host \
  --ulimit "memlock=-1:-1" \
  --name "${CONTAINER_NAME}" \
  --hostname "${NODE_NAME}" \
  --env "HOSTNAME=${NODE_NAME}" \
  --env "ELASTIC_USERNAME=${ELASTIC_USERNAME}" \
  --env "ELASTIC_PASSWORD=${ELASTIC_PASSWORD}" \
  --env "node.name=${NODE_NAME}" \
  --env "ES_JAVA_OPTS=${ES_JAVA_OPTS}" \
  --env "discovery.seed_hosts=${SEED_HOSTS}" \
  --env "discovery.zen.minimum_master_nodes=3" \
  --env "cluster.name=${CLS_NAME}" \
  --env "cluster.publish.timeout=90s" \
  --env "cluster.initial_master_nodes=${SEED_HOSTS}" \
  --env "transport.tcp.compress=true" \
  --env "network.host=${NETWORK_HOST}" \
  --env "node.master=true" \
  --env "node.ingest=true" \
  --env "node.data=true" \
  --env "node.ml=false" \
  --env "node.remote_cluster_client=true" \
  --env "xpack.security.enabled=true" \
  --env "xpack.security.http.ssl.enabled=true" \
  --env "xpack.security.http.ssl.keystore.path=/usr/share/elasticsearch/config/certs/elastic-certificates.p12" \
  --env "xpack.security.http.ssl.truststore.path=/usr/share/elasticsearch/config/certs/elastic-certificates.p12" \
  --env "xpack.security.transport.ssl.enabled=true" \
  --env "xpack.security.transport.ssl.verification_mode=certificate" \
  --env "xpack.security.transport.ssl.keystore.path=/usr/share/elasticsearch/config/certs/elastic-certificates.p12" \
  --env "xpack.security.transport.ssl.truststore.path=/usr/share/elasticsearch/config/certs/elastic-certificates.p12" \
  --env "reindex.remote.whitelist=${WHITELIST}" \
  --volume "${DATA_PATH}/snapshot:/snapshot:rw" \
  --volume "${DATA_PATH}/data:/usr/share/elasticsearch/data:rw" \
  "${DOCKER_IMAGE}"

sleep 30
chown -R 1000:1000 "${DATA_PATH}"
