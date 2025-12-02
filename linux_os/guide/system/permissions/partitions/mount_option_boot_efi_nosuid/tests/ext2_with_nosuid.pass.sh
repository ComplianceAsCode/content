#!/bin/bash
# remediation = none

# This test verifies that the rule passes when /boot/efi is mounted with ext2 filesystem
# and nosuid option is set

. $SHARED/partition.sh

clean_up_partition /boot/efi

# Create an ext2 partition
create_partition

# Add to fstab with nosuid option
mkdir -p /boot/efi
make_fstab_given_partition_line /boot/efi ext2 nosuid

# Mount the partition
mount /boot/efi
