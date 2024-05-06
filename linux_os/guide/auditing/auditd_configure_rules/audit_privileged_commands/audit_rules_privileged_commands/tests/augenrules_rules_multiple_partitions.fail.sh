#!/bin/bash
# packages = audit
# platform = multi_platform_fedora,multi_platform_rhel,Oracle Linux 7,Oracle Linux 8

. $SHARED/partition.sh

for num in 1 2; do
    # PARTITION variable is used in $SHARED/partition.sh
    PARTITION="/dev/new_partition$num"
    MOUNT_POINT="/mnt/partition$num"

    mkdir -p $MOUNT_POINT
    create_partition
    make_fstab_given_partition_line $MOUNT_POINT ext2
    mount_partition $MOUNT_POINT

    touch $MOUNT_POINT/priv_cmd
    chmod +xs $MOUNT_POINT/priv_cmd
done
