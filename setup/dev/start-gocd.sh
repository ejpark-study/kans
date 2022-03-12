#!/usr/bin/env bash

echo "### start-gocd.sh"
set -x #echo on

DNS_NAME=${1-"gocd.mlops"}
DATA_PATH=${2-"/data/gocd"}
SERVER_IMAGE=${3-"gocd/gocd-server:v21.4.0"}
AGENT_IMAGE=${4-"harbor.mlops/library/gocd-agent:v21.4.0"}
#AGENT_IMAGE=${4-"gocd/gocd-agent-ubuntu-20.04:v21.4.0"}
ROOT_CERTS_PATH=${5-"/usr/local/bin/setup/config/certs"}

# certs
CERTS_PATH="${DATA_PATH}/certs"
mkdir -p "${CERTS_PATH}"
chown -R "$(id -u):$(id -g)" "${DATA_PATH}"

if [[ ! -f "${DATA_PATH}/certs/${DNS_NAME}.crt" ]]; then
  /usr/local/bin/setup/certs/root-certs.sh "${DNS_NAME}" "${ROOT_CERTS_PATH}"
  /usr/local/bin/setup/certs/certs.sh "${DNS_NAME}" "${CERTS_PATH}" "${ROOT_CERTS_PATH}"
fi

# stop container
docker stop gocd-agent && docker rm gocd-agent
docker stop gocd-server && docker rm gocd-server

# harbor login
docker login harbor.mlops -u admin -p ChangeMe!

#  --publish 80:8153
#  --publish 443:8154

# server
docker run \
  --detach --restart unless-stopped \
  --name gocd-server \
  --hostname gocd-server \
  --user root:root \
  --network host \
  --volume "${DATA_PATH}:/godata" \
  --volume "${DATA_PATH}/certs:/home/go/certs" \
  --volume /etc/timezone:/etc/timezone:ro \
  --volume /etc/localtime:/etc/localtime:ro \
  "${SERVER_IMAGE}"

# agent
docker run \
  --detach --restart unless-stopped \
  --name gocd-agent \
  --hostname gocd-agent \
  --user root:root \
  --network host \
  --env "GO_SERVER_URL=http://${DNS_NAME}:8153/go" \
  --volume /etc/timezone:/etc/timezone:ro \
  --volume /etc/localtime:/etc/localtime:ro \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  "${AGENT_IMAGE}"

# wait for gocd init.
echo "wait for gocd init. (2 mins)"
sleep 120

docker exec -it gocd-server git config --global http.sslVerify false
docker exec -it gocd-agent git config --global http.sslVerify false
