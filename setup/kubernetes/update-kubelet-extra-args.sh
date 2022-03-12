#!/usr/bin/env bash

echo "### update-kubelet-extra-args.sh"
set -x #echo on

NODE_IP=${1:-"192.168.56.31"}

# NODE with INTERNAL-IP: https://docs.cilium.io/en/v1.9/gettingstarted/kubeproxy-free/

if [[ "${NODE_IP}" == "" ]]; then
  exit 0
fi

echo KUBELET_EXTRA_ARGS="--node-ip=${NODE_IP}" | tee -a /etc/default/kubelet
systemctl daemon-reload && systemctl restart kubelet

#echo Environment="KUBELET_EXTRA_ARGS=--node-ip=${NODE_IP}" | tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
