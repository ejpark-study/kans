#!/usr/bin/env bash

echo "### focal-core.sh"
set -x #echo on

USER_NAME=${1-"ubuntu"}

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
export LANG=C.UTF-8 LC_ALL=C.UTF-8
export NOTVISIBLE="in users profile"

apt update -yq

apt install -yqq \
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

apt install -yqq zsh

apt install -yqq iptables ipvsadm

#DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt upgrade -yqq Dpkg::Options::='--force-confnew'

# locale
locale-gen "en_US.UTF-8"
locale-gen "ko_KR.UTF-8"
locale-gen "ko_KR.EUC-KR"
update-locale LANG=ko_KR.UTF-8
dpkg-reconfigure --frontend noninteractive locales

# timezone
ln -fs /usr/share/zoneinfo/Asia/Seoul /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

# nopasswd
cat /etc/sudoers | perl -ple 's/(.+sudo.+) ALL/$1 NOPASSWD:ALL/g' > /tmp/sudoers && cat /tmp/sudoers > /etc/sudoers

# swapoff
swapoff -a
sed -i '/swap/d' /etc/fstab

# clean tmp
apt autoremove -yqq

# create workspace
mkdir -p /{workspace,share,data}
chown "${USER_NAME}:${USER_NAME}" /{workspace,share,data}

# Disable AppArmor
systemctl stop ufw && systemctl disable ufw
systemctl stop apparmor && systemctl disable apparmor

# minio client
if [[ ! -f /usr/local/bin/mc ]]; then
  wget -q -O /usr/local/bin/mc "https://dl.min.io/client/mc/release/linux-amd64/mc"
  chmod +x /usr/local/bin/mc
fi

# disable motd message
chmod -x /etc/update-motd.d/*
