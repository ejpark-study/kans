#!/usr/bin/env bash

echo "### kubernetes-init.sh"
set -x #echo on

MASTER_IP=${1:-"192.168.56.41"}
SVC_CIDR=${2:-"10.50.0.0/16"}
POD_NETWORK_CIDR=${3:-"10.244.0.0/16"}
CONTEXT_NAME=${4:-"dev"}
USERNAME=${5:-"ubuntu"}
SKIP_PROXY=${6:-"use-kube-proxy"}

# init kubernetes
EXTRA_PARAMS=
if [[ "${SKIP_PROXY}" == "disable-kube-proxy" ]]; then
  EXTRA_PARAMS="--skip-phases=addon/kube-proxy"
fi

kubeadm init \
  ${EXTRA_PARAMS} \
  --service-cidr="${SVC_CIDR}" \
  --pod-network-cidr="${POD_NETWORK_CIDR}" \
  --apiserver-advertise-address="${MASTER_IP}" \
  | grep -Ei "kubeadm join|discovery-token-ca-cert-hash" \
  | tee "/tmp/join.sh"

# kube-config: root & user account
mkdir -p "/root/.kube" "/home/${USERNAME}/.kube"
cat /etc/kubernetes/admin.conf > "/root/.kube/config"

kubectl config rename-context "kubernetes-admin@kubernetes" "${CONTEXT_NAME}"

cat "/root/.kube/config" > "/home/${USERNAME}/.kube/config"
chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}/.kube"

# kube-config permission
chmod 600 "/root/.kube/config" "/home/${USERNAME}/.kube/config"

# check nodes
kubectl get nodes -o wide
