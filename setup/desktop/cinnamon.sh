#!/usr/bin/env bash

echo "### cinnamon.sh"
set -x #echo on

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A6616109451BBBF2
apt-add-repository "deb http://ftp.kaist.ac.kr/linuxmint ulyana main upstream import backport"

apt update -yq

# cinnamon
apt install -yq \
    cinnamon-desktop-environment \
    crudini \
    fcitx-hangul \
    fontconfig \
    nemo \
    pulseaudio \
    tilix \
    xrdp

mkdir -p /run/dbus
dbus-daemon --system

systemctl enable dbus
systemctl enable xrdp

echo | tee /var/log/xrdp.log
echo | tee /var/log/xrdp-sesman.log

chown xrdp:adm /var/log/xrdp.log
chown root:adm /var/log/xrdp-sesman.log

service xrdp start

#tail -f /var/log/xrdp*.log

apt install -y \
  language-pack-ko \
  language-pack-gnome-ko \
  ibus-hangul
   
# -o 옵션에는 apt-get 으로 해야 함.
apt-get -o Dpkg::Options::="--force-overwrite" install -y \
  mint-info-cinnamon \
  mintdesktop \
  mintlocale \
  syslinux-themes-linuxmint \
  gnome-user-docs-ko 

apt install -y \
  linuxmint-keyring \
  mint-artwork \
  mint-backgrounds-ulyana \
  mint-mirrors \
  mint-themes \
  mint-upgrade-info \
  mint-x-icons \
  mint-y-icons \
  mintbackup \
  mintinstall \
  mintreport \
  mintstick \
  mintupdate \
  ubuntu-dbgsym-keyring \
  ubuntu-drivers-common \
  xdg-desktop-portal \
  xdg-desktop-portal-gtk
  
apt-get -o Dpkg::Options::="--force-overwrite" upgrade -yqq

# clean tmp
apt autoremove -yqq
