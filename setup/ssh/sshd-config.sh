#!/usr/bin/env bash

echo "### sshd-config.sh"
set -x #echo on

sed -i "s/#PasswordAuthentication/PasswordAuthentication/g" /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

grep "PasswordAuthentication" /etc/ssh/sshd_config

systemctl restart sshd.service
