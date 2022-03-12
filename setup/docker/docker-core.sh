#!/usr/bin/env bash

echo "### docker-core.sh"
set -x #echo on

VERSION=${1:-"5:20.10.12~3-0~ubuntu-focal"}

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

# docker repo
curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | apt-key add -
apt-add-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

apt update -yq
apt install -yqq "docker-ce=${VERSION}"

apt-mark hold docker-ce

# docker
systemctl enable docker
usermod -aG docker ubuntu

docker version

# docker-compose
if [[ ! -f $(which docker-compose) ]]; then
  curl -fsSL -o /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64"
  chmod +x /usr/local/bin/docker-compose
fi

docker-compose version
