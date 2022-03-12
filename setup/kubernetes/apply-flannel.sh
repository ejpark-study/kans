#!/usr/bin/env bash

echo "### apply-flannel.sh"
set -x #echo on

SKEL_PATH=${1:-"/usr/local/bin/setup/config/skel"}
IP_REANGE=${2:-"10.244.0.0/16"}

if [[ ! -f "${SKEL_PATH}/flannel.yaml" ]]; then
  curl -fsSL -o "${SKEL_PATH}/flannel.yaml" "https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml"
fi

#POD_NETWORK_CIDR=${1:-"10.244.0.0/16"}
# sed 's#("Network": ").+?"#\$1${POD_NETWORK_CIDR}#g' "${SKEL_PATH}/flannel.yaml"
#❯ cat "${SKEL_PATH}/flannel.yaml" | grep /16
#      "Network": "10.244.0.0/16",

kubectl apply -f "${SKEL_PATH}/flannel.yaml"
