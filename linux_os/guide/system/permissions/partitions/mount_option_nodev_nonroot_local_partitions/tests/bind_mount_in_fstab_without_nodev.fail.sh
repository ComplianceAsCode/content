#!/bin/bash

. $SHARED/partition.sh

# Add nodev option to all records in fstab to ensure that test will
# run on environment where everything is set correctly for rule check.
cp /etc/fstab /etc/fstab.backup
sed -i -e 's/\bnodev\b/,/g' -e 's/,,//g' -e 's/\s,\s/defaults/g' /etc/fstab.backup
awk '{$4 = $4",nodev"; print}' /etc/fstab.backup > /etc/fstab
# Remount all partitions. (--all option can't be used because it doesn't
# mount e.g. /boot partition
declare -a partitions=( $(awk '{print $2}' /etc/fstab | grep "^/\w") )
for partition in ${partitions[@]}; do
    mount -o remount "$partition"
done

PARTITION="/dev/new_partition1"; create_partition
make_fstab_given_partition_line "/tmp/partition1" ext2
mount_partition "/tmp/partition1"

# A bind mount with its own /etc/fstab entry and without nodev. findmnt shows
# its source as DEVICE[PATH]; the remediation adds nodev to the existing entry.
mkdir -p /tmp/partition1/bind_source
PARTITION="/tmp/partition1/bind_source"
make_fstab_given_partition_line "/tmp/bind_target" none bind
mount_partition "/tmp/bind_target"
