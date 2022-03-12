#!/usr/bin/env bash

echo "### apply-metallb.sh"
set -x #echo on

VERSION=${1:-"v0.12"}
SKEL_PATH=${2:-"/usr/local/bin/setup/config/skel"}
IP_RANGE=${3:-"192.168.56.31-192.168.56.33"}

if [[ ! -f "${SKEL_PATH}/metallb-namespace-${VERSION}.yaml" ]]; then
  curl -fsL -o "${SKEL_PATH}/metallb-namespace-${VERSION}.yaml" "https://raw.githubusercontent.com/metallb/metallb/${VERSION}/manifests/namespace.yaml"
  curl -fsL -o "${SKEL_PATH}/metallb-${VERSION}.yaml" "https://raw.githubusercontent.com/metallb/metallb/${VERSION}/manifests/metallb.yaml"
fi

kubectl apply -f "${SKEL_PATH}/metallb-namespace-${VERSION}.yaml"
kubectl apply -f "${SKEL_PATH}/metallb-${VERSION}.yaml"

cat <<EOF > "${SKEL_PATH}/metallb-config.yaml"
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - ${IP_RANGE}
EOF

kubectl apply -f "${SKEL_PATH}/metallb-config.yaml"
