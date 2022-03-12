#!/usr/bin/env bash

echo "### disk-mount.sh"
#set -x #echo on

DISK=${1-"/dev/sdb"}
DISK_PATH=${2-"/data"}
MOUNT_USER=${3-"ubuntu"}

# create mount path
if [[ ! -d "${DISK_PATH}" ]]; then
  mkdir -p "${DISK_PATH}"
fi

# change owner
chown "${MOUNT_USER}:${MOUNT_USER}" "${DISK_PATH}"

# mount
blkid | grep "${DISK}1" | cut -f2 -d'"' \
  | xargs -I{} echo "UUID={} ${DISK_PATH} ext4 defaults 0 1" | tee -a /etc/fstab

mount -a

echo "Mount Status: ${DISK_PATH}"
mount -l | grep "${DISK}1"
