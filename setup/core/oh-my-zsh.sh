#!/usr/bin/env bash

echo "### oh-my-zsh.sh"
set -x #echo on

SKEL_PATH=${1-"/usr/local/bin/setup/config/skel"}

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
export LANG=C.UTF-8 LC_ALL=C.UTF-8
export NOTVISIBLE="in users profile"

if [[ $(which zsh)  == "" ]]; then
  sudo apt update -yq
  sudo apt install -yqq zsh
fi

if [[ ! -f ~/.oh-my-zsh ]]; then
  # oh my zsh
  curl -fsSL "https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh" | zsh || true

  git clone --depth=1 "https://github.com/jonmosco/kube-ps1" ~/.kube-ps1
  git clone --depth=1 "https://github.com/zsh-users/zsh-completions.git" ~/.oh-my-zsh/plugins/zsh-completions
  git clone --depth=1 "https://github.com/zsh-users/zsh-autosuggestions.git" ~/.oh-my-zsh/plugins/zsh-autosuggestions
  git clone --depth=1 "https://github.com/zsh-users/zsh-syntax-highlighting.git" ~/.oh-my-zsh/plugins/zsh-syntax-highlighting

  cat "${SKEL_PATH}"/.zshrc > ~/.zshrc
fi

# change user zsh
sudo sed -i -e 's#/home/ubuntu:/bin/bash#/home/ubuntu:/usr/bin/zsh#' /etc/passwd

# pip mirror
if [[ ! -f ~/.pip ]]; then
  mkdir -p ~/.pip

  cat <<EOF | tee ~/.pip/pip.conf
[global]
timeout = 60
index-url = http://mirror.kakao.com/pypi/simple
trusted-host = mirror.kakao.com
EOF
fi

# disable login date
touch ~/.hushlogin