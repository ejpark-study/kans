#!/usr/bin/env bash

echo "### kubernetes-core.sh"
set -x #echo on

K8S_VERSION=${1:-"1.23.3"}

apt update -yq

apt install -yq \
  apt-transport-https \
  apt-utils \
  ca-certificates \
  curl \
  dconf-cli \
  gnupg \
  gpg \
  libcurl4-openssl-dev \
  libssl-dev \
  software-properties-common

# Letting iptables see bridged traffic
cat <<EOF1 | tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF1

sysctl --system

# kubernetes repo
curl -fsSL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | apt-key add -
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

apt update -yq

apt install -yqq --allow-downgrades --allow-change-held-packages \
  etcd-client \
  kubelet="${K8S_VERSION}-00" \
  kubectl="${K8S_VERSION}-00" \
  kubeadm="${K8S_VERSION}-00"

apt-mark hold kubelet kubeadm kubectl

systemctl enable kubelet && systemctl start kubelet
