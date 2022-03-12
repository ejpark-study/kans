#!/usr/bin/env bash

echo "### download-certs.sh"
set -x #echo on

DNS_NAME=${1-"gitlab.mlops"}

CA_PATH="/usr/local/share/ca-certificates/${DNS_NAME}"

# extract certs from url
true | openssl s_client -connect "${DNS_NAME}:443" | tee /tmp/certlog
openssl x509 -inform PEM -text -in /tmp/certlog -out /tmp/ca-bundle.crt

# check
openssl x509 -inform PEM -text -in /tmp/ca-bundle.crt

# add
mkdir -p "${CA_PATH}"
mv /tmp/ca-bundle.crt "${CA_PATH}/ca-bundle.crt"
update-ca-certificates

# check
awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}' \
  < /etc/ssl/certs/ca-certificates.crt | grep "${DNS_NAME}"
