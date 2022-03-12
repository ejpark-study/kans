#!/usr/bin/env bash

echo "### ssh-keygen.sh"
set -x #echo on

CONFIG_PATH=${1:-"/usr/local/bin/setup/config/.ssh"}

if [[ ! -d ~/.ssh ]]; then
  mkdir ~/.ssh
fi

# Change Permission
echo "Change Permission: ~/.ssh"
chmod 700 ~/.ssh

# ssh key
if [[ -f "${CONFIG_PATH}/id_rsa" ]]; then
  cp "${CONFIG_PATH}"/id_rsa* ~/.ssh/
else
  yes 'y' | ssh-keygen -t rsa -q -f ~/.ssh/id_rsa -N ''
fi

cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# ssh config
if [[ -f "${CONFIG_PATH}/config" ]]; then
  cat "${CONFIG_PATH}/config" > ~/.ssh/config
  chmod 600 ~/.ssh/config
fi

if [[ -f ~/.ssh/id_rsa ]]; then
  chmod 600 ~/.ssh/id_rsa
  chmod 644 ~/.ssh/id_rsa.pub
fi