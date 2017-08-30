#!/bin/bash

PARTITION="/root/new_partition"

dd if=/dev/zero of=$PARTITION bs=1M count=50
mkfs.ext2 -F $PARTITION
mount $PARTITION /tmp
echo "$PARTITION      /tmp     none     rw,nodev,noexec,nosuid,bind     0 0" >> /etc/fstab
