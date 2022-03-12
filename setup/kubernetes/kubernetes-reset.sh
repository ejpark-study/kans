#!/usr/bin/env bash

echo "### kubernetes-reset.sh"
set -x #echo on

WORKER_LIST=${1:-"worker1.mlops,worker2.mlops"}

kubeadm reset -f

rm -rf /etc/cni/net.d
ipvsadm --clear && iptables -F && iptables -t nat -F && iptables -t mangle -F

# reset worker
for node in ${WORKER_LIST//,/ }; do
  ssh "${node}" "kubeadm reset -f"

  ssh "${node}" "rm -rf /etc/cni/net.d"
  ssh "${node}" "ipvsadm --clear && iptables -F && iptables -t nat -F && iptables -t mangle -F"
done
