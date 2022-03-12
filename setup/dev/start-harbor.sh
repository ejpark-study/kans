#!/usr/bin/env bash

echo "### start-harbor.sh"
set -x #echo on

DNS_NAME=${1-"harbor.mlops"}
CERTS_PATH=${2-"/data/harbor/certs"}
INSTALL_PATH=${3-"/setup/harbor"}
SKEL_PATH=${4:-"/usr/local/bin/setup/config/skel"}

mkdir -p "${CERTS_PATH}"

if [[ ! -f "${CERTS_PATH}/${DNS_NAME}.crt" ]]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/CN=${DNS_NAME}/O=${DNS_NAME}-tls" \
    -out "${CERTS_PATH}/${DNS_NAME}.crt" \
    -keyout "${CERTS_PATH}/${DNS_NAME}.key"
fi

if [[ ! -f $(which docker-compose) ]]; then
  wget -q -O /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64"
  chmod +x /usr/local/bin/docker-compose
fi

#curl -fsSL -o harbor-offline-installer-v2.4.1.tgz "https://github.com/goharbor/harbor/releases/download/v2.4.1/harbor-offline-installer-v2.4.1.tgz"
cat "${SKEL_PATH}/harbor.yml" > "${INSTALL_PATH}/harbor.yml"
cd "${INSTALL_PATH}" && bash ./install.sh

# docker login -u admin -p ChangeMe! harbor.mlops