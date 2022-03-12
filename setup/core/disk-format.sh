#!/usr/bin/env bash

echo "### disk-format.sh"
#set -x #echo on

DISK=${1-"/dev/sdb"}

# check disk
if [[ $(fdisk -l | grep "${DISK}1") != "" ]]; then
  echo "Skip Disk Exists: ${DISK}"
  exit 0
fi

# create partition
echo "Create Partition: ${DISK}"

parted "${DISK}" mklabel gpt
parted "${DISK}" mkpart primary 1 100%
parted "${DISK}" align-check min 1

# format disk
echo "Format Disk: ${DISK}1"
mkfs.ext4 "${DISK}1"
