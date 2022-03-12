#!/usr/bin/env bash

echo "### kubernetes-utils.sh"
set -x #echo on

if [[ ! -f $(which helm) ]]; then
  echo "# helm 설치"
  curl -fsSL -o /tmp/get_helm.sh "https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3"
  bash /tmp/get_helm.sh && rm /tmp/get_helm.sh
fi

if [[ ! -f $(which k9s) ]]; then
  echo "# k9s 설치"
  export K9S_VER="v0.25.18"

  curl -fsSL -o /tmp/k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VER}/k9s_Linux_x86_64.tar.gz"
  tar xfz /tmp/k9s.tar.gz -C /tmp && mv /tmp/k9s /usr/bin/
fi

if [[ ! -f $(which stern) ]]; then
  echo "# stern 설치"
  export STERN_VER="1.11.0"

  curl -fsSL -o /usr/bin/stern "https://github.com/wercker/stern/releases/download/${STERN_VER}/stern_linux_amd64"
  chmod +x /usr/bin/stern
fi

if [[ ! -f $(which krew) ]]; then
  echo "# krew 설치"
  curl -fsSL -o /tmp/krew.tar.gz "https://github.com/kubernetes-sigs/krew/releases/download/v0.4.2/krew-linux_amd64.tar.gz"
  tar xfz /tmp/krew.tar.gz -C /tmp && mv /tmp/krew-linux_amd64 /usr/bin/krew && chmod +x /usr/bin/krew
fi

if [[ ! -f $(which kubetail) ]]; then
  echo "# kube-tail 설치"
  curl -fsSL -o /usr/bin/kubetail "https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail"
  chmod +x /usr/bin/kubetail

  curl -fsSL -o /usr/bin/kubetail.bash "https://raw.githubusercontent.com/johanhaleby/kubetail/master/completion/kubetail.bash"
fi
