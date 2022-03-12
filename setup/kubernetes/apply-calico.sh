#!/usr/bin/env bash

echo "### apply-calico.sh"
set -x #echo on

SKEL_PATH=${1:-"/usr/local/bin/setup/config/skel"}

if [[ ! -f "${SKEL_PATH}/calico.yaml" ]]; then
#  curl -fsSL -o "${SKEL_PATH}/calico.yaml" "https://docs.projectcalico.org/manifests/calico.yaml"
  curl -fsSL -o "${SKEL_PATH}/calico.yaml" "https://projectcalico.docs.tigera.io/manifests/calico.yaml"
fi

if [[ ! -f $(which calicoctl) ]]; then
  curl -fsSL -o /usr/local/bin/calicoctl "https://github.com/projectcalico/calico/releases/download/v3.22.0/calicoctl-linux-amd64"
  chmod +x /usr/local/bin/calicoctl
fi

kubectl apply -f "${SKEL_PATH}/calico.yaml"