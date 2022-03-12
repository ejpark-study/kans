#!/usr/bin/env bash

echo "### root-certs.sh"
set -x #echo on

DNS_NAME=${1-"mlops"}
CERTS_PATH=${2-"/usr/local/bin/setup/config/certs"}

if [[ -f "${CERTS_PATH}/rootCA.key" ]]; then
  exit 0
fi

mkdir -p "${CERTS_PATH}"

# certificate key
openssl genrsa -out "${CERTS_PATH}/rootCA.key" 2048

# root certificate
cat <<EOF > "${CERTS_PATH}/rootCA.conf"
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]

[ v3_ca ]
basicConstraints = critical,CA:TRUE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer:always

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DNS_NAME}
DNS.2 = *.${DNS_NAME}
EOF

# create rootCA
openssl req -x509 -new -nodes -sha256 -days 365 \
  -reqexts v3_req -extensions v3_ca \
  -subj "/C=KO/ST=Seoul/O=MLOps Development/CN=${DNS_NAME},*.${DNS_NAME}" \
  -config "${CERTS_PATH}/rootCA.conf" \
  -key "${CERTS_PATH}/rootCA.key" -out "${CERTS_PATH}/rootCA.crt"

# check rootCA
openssl x509 -in "${CERTS_PATH}/rootCA.crt" -noout -text

# add linux rootCA
cp "${CERTS_PATH}/rootCA.crt" "/usr/local/share/ca-certificates/${DNS_NAME}.crt"

#Update the certificate store.
update-ca-certificates

# check
awk -v cmd='openssl x509 -noout -subject' '/BEGIN/{close(cmd)};{print | cmd}' \
  < /etc/ssl/certs/ca-certificates.crt | grep "${DNS_NAME}"
