#!/usr/bin/env bash

echo "### user-passwd.sh"
set -x #echo on

USERNAME=${1:-"ubuntu"}
PASSWORD=${2:-"ubuntu"}

echo "${USERNAME}:${PASSWORD}" | chpasswd
#echo "vagrant:vagrant" | chpasswd
