#!/bin/bash

. $SHARED/partition.sh

# Add nodev option to all records in fstab to ensure that test will
# run on environment where everything is set correctly for rule check.
cp /etc/fstab /etc/fstab.backup
sed -e 's/\bnodev\b/,/g' -e 's/,,//g' -e 's/\s,\s/defaults/g' /etc/fstab.backup
awk '{$4 = $4",nodev"; print}' /etc/fstab.backup > /etc/fstab
# Remount all partitions. (--all option can't be used because it doesn't
# mount e.g. /boot partition
declare -a partitions=( $(awk '{print $2}' /etc/fstab | grep "^/\w") )
for partition in ${partitions[@]}; do
    mount -o remount "$partition"
done

PARTITION="/dev/new_partition1"; create_partition
make_fstab_given_partition_line "/tmp/partition1" ext2 nodev
mount_partition "/tmp/partition1"

PARTITION="/dev/new_partition2"; create_partition
make_fstab_given_partition_line "/tmp/partition2" ext2
mount_partition "/tmp/partition2"
