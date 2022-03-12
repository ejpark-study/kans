#!/usr/bin/env bash

echo "### apply-metrics-server.sh"
set -x #echo on

SKEL_PATH=${1:-"/usr/local/bin/setup/config/skel"}

# metrics-server
if [[ ! -f "${SKEL_PATH}/metrics-server.yaml" ]]; then
  curl -fsSL -o "${SKEL_PATH}/metrics-server.yaml" "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
  sed -i'' -r -e "/- --secure-port=4443/a\        - --kubelet-insecure-tls" "${SKEL_PATH}/metrics-server.yaml"
fi

kubectl apply -f "${SKEL_PATH}/metrics-server.yaml"
