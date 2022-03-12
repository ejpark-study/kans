#!/usr/bin/env bash

echo "### upgrade-kernel.sh"
set -x #echo on

apt update -yq

apt install -yqq linux-generic-hwe-20.04

apt autoremove -yq
