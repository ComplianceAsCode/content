#!/bin/bash

# This test verifies that the rule passes when /boot/efi is mounted with vfat filesystem
# Even with nosuid set, vfat is excluded from the requirement (nosuid has no effect on vfat)

. $SHARED/partition.sh

clean_up_partition /boot/efi

# Create a vfat partition
VFAT_PARTITION="/root/vfat_partition"
dd if=/dev/zero of=$VFAT_PARTITION bs=1M count=50
mkfs.vfat $VFAT_PARTITION

# Add to fstab with nosuid option (should still pass because vfat is excluded)
mkdir -p /boot/efi
echo "$VFAT_PARTITION /boot/efi vfat rw,nosuid,relatime 0 0" >> /etc/fstab

# Mount the partition
mount /boot/efi
