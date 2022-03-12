#!/usr/bin/env bash

echo "### compact.sh"
set -x #echo on

# clean tmp
apt autoremove -yqq

# zerofill
#dd if=/dev/zero | pv | dd of=/tmp/zerofill bs=4096k
dd if=/dev/zero of=/tmp/zerofill bs=4096k

rm -rf /tmp/zerofill

# swapfile
if [[ -f /swapfile ]]; then rm -rf /swapfile; fi
