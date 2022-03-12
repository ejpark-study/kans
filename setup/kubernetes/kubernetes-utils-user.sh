#!/usr/bin/env bash

echo "### kubernetes-utils-user.sh"
set -x #echo on

# krew 설치
if [[ -f $(which krew) ]]; then
  krew install krew

  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  kubectl krew update

  kubectl krew install ctx
  kubectl krew install ns
  kubectl krew install konfig
  kubectl krew install neat
  kubectl krew install ingress-nginx
fi

# kubeconfig dir
if [[ -f ~/.kube/config ]]; then
  chmod o-r ~/.kube/config
  chmod g-r ~/.kube/config
fi
