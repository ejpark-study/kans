#!/usr/bin/env bash

echo "### xrdp.sh"
set -x #echo on

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
export LANG=C.UTF-8 LC_ALL=C.UTF-8
export NOTVISIBLE="in users profile"

# chrome
curl -fsSL "https://dl-ssl.google.com/linux/linux_signing_key.pub" | apt-key add -
apt-add-repository "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"

# vscode
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EB3E94ADBE1229CF

curl -fsSL "https://packages.microsoft.com/keys/microsoft.asc" | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg
apt-add-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"

apt update -yq

apt install -yqq ffmpeg

# chrome
apt install -yqq \
  chromium \
  code \
  flameshot \
  fontconfig \
  google-chrome-stable \
  nemo \
  pdftk \
  pulseaudio \
  tilix \
  vlc

apt install -yqq \
  language-pack-ko \
  language-pack-gnome-ko \
  ibus-hangul

ln -s /etc/profile.d/vte-*.sh /etc/profile.d/vte.sh

# xrdp
#apt install -yq crudini xrdp

#crudini --set /etc/xrdp/xrdp.ini Globals max_bpp 128
#crudini --set /etc/xrdp/xrdp.ini Xorg xserverbpp 32
#
#crudini --set /etc/xrdp/xrdp.ini Xorg username ubuntu
#crudini --set /etc/xrdp/xrdp.ini Xorg password ubuntu
#
#echo "cinnamon-session" > /etc/skel/.Xclients

#adduser xrdp ssl-cert

# clean tmp
apt autoremove -yqq
