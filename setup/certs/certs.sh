#!/usr/bin/env bash

echo "### certs.sh"
set -x #echo on

DNS_NAME=${1-"gitlab.mlops"}
CERTS_PATH=${2-"/etc/certs"}
ROOT_CERTS_PATH=${3-"/usr/local/bin/setup/config/certs"}

if [[ -f "${CERTS_PATH}/${DNS_NAME}.key" ]]; then
  exit 0
fi

mkdir -p "${CERTS_PATH}"

# Create a certificate (Done for each server)
openssl genrsa -out "${CERTS_PATH}/${DNS_NAME}.key" 2048

# Create the signing (csr)
openssl req -new -sha256 \
  -reqexts v3_req -extensions v3_ca \
  -subj "/C=KO/ST=Seoul/O=MLOps Development/CN=${DNS_NAME}" \
  -key "${CERTS_PATH}/${DNS_NAME}.key" -out "${CERTS_PATH}/${DNS_NAME}.csr"

# check csr
openssl req -noout -text -in "${CERTS_PATH}/${DNS_NAME}.csr"

# Generate the certificate using the csr and key along with the CA Root key
cat <<EOF > "${CERTS_PATH}/${DNS_NAME}.ext"
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DNS_NAME}
EOF

# create certs
openssl x509 -req -days 365 -sha256 -CAcreateserial \
  -CA "${ROOT_CERTS_PATH}/rootCA.crt" -CAkey "${ROOT_CERTS_PATH}/rootCA.key" \
  -extfile "${CERTS_PATH}/${DNS_NAME}.ext" \
  -in "${CERTS_PATH}/${DNS_NAME}.csr" -out "${CERTS_PATH}/${DNS_NAME}.crt"

# check
openssl x509 -text -noout -in "${CERTS_PATH}/${DNS_NAME}.crt"
