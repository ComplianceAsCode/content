#!/bin/bash

# This test verifies that the rule fails when /boot/efi
# is mounted with vfat without the nosuid option

# packages = dosfstools

. $SHARED/partition.sh

clean_up_partition /boot/efi

# Create a vfat partition
VFAT_PARTITION="/root/vfat_partition"
dd if=/dev/zero of=$VFAT_PARTITION bs=1M count=50
mkfs.vfat $VFAT_PARTITION

# Add to fstab without the nosuid option
mkdir -p /boot/efi
echo "$VFAT_PARTITION /boot/efi vfat rw,relatime,loop 0 0" >> /etc/fstab

# Mount the partition
mount /boot/efi
