#!/bin/bash

# This test verifies that the rule passes when /boot/efi is mounted with vfat filesystem

# packages = dosfstools

. $SHARED/partition.sh

clean_up_partition /boot/efi

# Create a vfat partition
VFAT_PARTITION="/root/vfat_partition"
dd if=/dev/zero of=$VFAT_PARTITION bs=1M count=50
mkfs.vfat $VFAT_PARTITION

# Add to fstab with nosuid option
mkdir -p /boot/efi
echo "$VFAT_PARTITION /boot/efi vfat rw,nosuid,relatime,loop 0 0" >> /etc/fstab

# Mount the partition
mount /boot/efi

# Add verification step to ensure the mount is active and correct
# This helps the script exit with a failure if mount failed unexpectedly
findmnt --target /boot/efi > /dev/null 2>&1
