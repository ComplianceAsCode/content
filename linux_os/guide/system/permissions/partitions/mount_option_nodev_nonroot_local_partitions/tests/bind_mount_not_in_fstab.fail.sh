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

# A partition without nodev, so that the rule fails and gets remediated.
PARTITION="/dev/new_partition1"; create_partition
make_fstab_given_partition_line "/tmp/partition1" ext2
mount_partition "/tmp/partition1"

# A bind mount without an /etc/fstab entry, of a directory on a partition
# mounted with nodev (the bind mount inherits nodev). findmnt shows its
# source as DEVICE[PATH], which the remediation must not add to /etc/fstab.
PARTITION="/dev/new_partition2"; create_partition
make_fstab_given_partition_line "/tmp/partition2" ext2 nodev
mount_partition "/tmp/partition2"
mkdir -p /tmp/partition2/bind_source /tmp/bind_target
mount --bind /tmp/partition2/bind_source /tmp/bind_target
