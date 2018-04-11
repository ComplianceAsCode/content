#!/bin/bash

PARTITION="/root/new_partition"

create_partition() {
	dd if=/dev/zero of=$PARTITION bs=1M count=50
	mkfs.ext2 -F $PARTITION
}

# $1: The mount point
# $2: The additional mount options
make_fstab_given_partition_line() {
	local _mount_point="$1" _additional_mount_options="$2"
	test -z "$_additional_mount_options" || _additional_mount_options=",$_additional_mount_options"
	printf "%s     %s     ext2     rw%s     0 0\n" "$PARTITION" "$_mount_point" "$_additional_mount_options" > /etc/fstab
}

# $1: The mount point
make_fstab_correct_partition_line() {
	make_fstab_given_partition_line "$1" "nodev,noexec,nosuid"
}

# $1: The mount point
mount_partition() {
	mkdir -p "$1"
	# mount "$PARTITION" "$1"
	mount --target "$1"
}

mount_bind_partition() {
	mkdir -p "$1"
	# mount -B "$PARTITION" "$1"
	mount --target -B "$1"
}
