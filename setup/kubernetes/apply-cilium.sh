#!/usr/bin/env bash

echo "### apply-cilium.sh"
set -x #echo on

CILIUM_VERSION=${1-"1.11.2"}
MASTER_IP=${2-"192.168.56.31"}
ROUTING_CIDR=${3-"192.168.56.0/16"}

if [[ ! -f $(which cilium) ]]; then
  curl -fsSL -o /tmp/cilium.tar.gz "https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz"
  tar xfz /tmp/cilium.tar.gz -C /usr/local/bin && rm /tmp/cilium.tar.gz
fi

echo 'net.ipv4.conf.lxc*.rp_filter = 0' > /etc/sysctl.d/99-override_cilium_rp_filter.conf
systemctl restart systemd-sysctl

#cilium install

helm repo add cilium https://helm.cilium.io/

helm install cilium cilium/cilium \
  --version "${CILIUM_VERSION}" \
  --namespace kube-system \
  --set k8sServiceHost="${MASTER_IP}" \
  --set k8sServicePort=6443 \
  --set debug.enabled=true \
  --set autoDirectNodeRoutes=true \
  --set endpointRoutes.enabled=true \
  --set ipam.mode=kubernetes \
  --set k8s.requireIPv4PodCIDR=true \
  --set kubeProxyReplacement=strict \
  --set ipv4NativeRoutingCIDR="${ROUTING_CIDR}" \
  --set tunnel=disabled \
  --set egressGateway.enabled=true \
  --set enableIPv4Masquerade=true \
  --set bpf.masquerade=true \
  --set bpf.hostRouting=true \
  --set loadBalancer.mode=dsr \
  --set bandwidthManager=true \
  --set prometheus.enabled=true \
  --set operator.replicas=1 \
  --set operator.prometheus.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set hubble.metrics.enabled="{dns:query;ignoreAAAA,drop,tcp,flow,icmp,http}" \
  --set externalIPs.enabled=true \
  --set config.sessionAffinity=true \
  --set hostServices.enabled=true \
  --set nodePort.enabled=true \
  --set hostPort.enabled=true

#  error
#  --set loadBalancer.acceleration=native


# Minimum Kernel Version >= 5.7: bpf.masquerade=false, bpf.hostRouting=false
# https://docs.cilium.io/en/v1.9/operations/system_requirements/

# Install Hubble Client
#export HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
if [[ ! -f /usrl/local/bin/hubble ]]; then
  curl -s -L --remote-name-all -o /tmp/hubble.tar.gz "https://github.com/cilium/hubble/releases/download/v0.9.0/hubble-linux-amd64.tar.gz"
  tar xzfC /tmp/hubble.tar.gz /usr/local/bin && rm /tmp/hubble.tar.gz
fi

# kernel version
uname -a
