#!/usr/bin/env bash

echo "### apply-ingress.sh"
set -x #echo on

VERSION=${1:-"v1.1.1"}
SKEL_PATH=${2:-"/usr/local/bin/setup/config/skel"}

if [[ ! -f "${SKEL_PATH}/nginx-ingress-${VERSION}.yaml" ]]; then
  curl -fsL -o "${SKEL_PATH}/nginx-ingress-${VERSION}.yaml" "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-${VERSION}/deploy/static/provider/cloud/deploy.yaml"
fi

kubectl apply -f "${SKEL_PATH}/nginx-ingress-${VERSION}.yaml"
