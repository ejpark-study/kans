#!/usr/bin/env bash

echo "### docker-config.sh"
set -x #echo on

BIP=${1-"10.10.0.1/16"}
ADDRESS_POOLS=${2-"10.11.0.1/16"}

# cgroup Driver systemd
mkdir -p /etc/docker

cat <<EOF | tee /etc/docker/daemon.json
{
  "bip": "${BIP}",
  "default-address-pools":[
    {"base":"${ADDRESS_POOLS}", "size":24}
  ],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "data-root": "/var/lib/docker",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "dns": [
    "8.8.8.8"
  ],
  "registry-mirrors": [
    "https://mirror.gcr.io"
  ],
  "insecure-registries": [
    "harbor.mlops"
  ]
}
EOF

# restart docker
systemctl daemon-reload && systemctl restart docker
