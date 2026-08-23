#!/bin/bash

# This test verifies that the rule fails when /boot/efi is mounted with ext2 filesystem
# without nosuid option

. $SHARED/partition.sh

clean_up_partition /boot/efi

# Create an ext2 partition
create_partition

# Add to fstab without nosuid option
mkdir -p /boot/efi
make_fstab_given_partition_line /boot/efi ext2 rw

# Mount the partition
mount /boot/efi
