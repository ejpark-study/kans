#!/usr/bin/env bash

echo "### clear-cache.sh"
set -x #echo on

# clean tmp
apt autoremove -yqq

cat <<EOF | xargs -I{} rm -rf {}
/tmp/*
/var/tmp/*
/var/log/*
/var/cache/*
/var/lib/apt/lists/*
/root/.cache
/home/ubuntu/.cache
/home/vagrant/.cache
EOF
