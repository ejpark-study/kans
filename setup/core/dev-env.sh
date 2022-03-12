#!/usr/bin/env bash

echo "### dev-env.sh"
set -x #echo on

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
export LANG=C.UTF-8 LC_ALL=C.UTF-8
export NOTVISIBLE="in users profile"

apt update -yq

apt install -yqq \
  bash \
  bzip2 \
  cmake \
  curl \
  git \
  htop \
  jq \
  less \
  libdb-dev \
  ffmpeg \
  locales \
  make \
  p7zip \
  pbzip2 \
  perl \
  pv \
  parallel \
  rename \
  sqlite \
  sudo \
  tmux \
  unzip \
  vim \
  wget \
  zsh

apt install -yqq \
  arp-scan \
  bridge-utils \
  conntrack \
  etcd-client \
  ipset \
  iputils-arping \
  ipvsadm \
  net-tools \
  ngrep \
  nmap \
  resolvconf \
  tree \
  wireguard

apt install -yqq \
  build-essential \
  python3 \
  python3-dev \
  python3-pip \
  python3-venv \
  sqlite3

# install python based tools

pip3 install -U wheel setuptools pip
pip3 install youtube-dl sshuttle glances
pip3 install csvkit docx2txt kube-shell
pip3 install python-gitlab

# nodejs
curl -sL "https://deb.nodesource.com/setup_16.x" | bash -

apt update -yq
apt install -yqq nodejs

# gitlab cli: https://github.com/profclems/glab
curl -sL "https://raw.githubusercontent.com/profclems/glab/trunk/scripts/install.sh" | bash -

# install nodejs based tools
#npm install --global --save csvtojson

# clean tmp
apt autoremove -yqq
