#!/bin/bash

PARTITION="/root/new_partition"

create_partition() {
	# Some scenarios re-mount this device as '/tmp', therefore its size
	# needs to be enough for the produced logs.
	dd if=/dev/zero of=$PARTITION bs=1M count=200
	mkfs.ext2 -F $PARTITION
}

# $1: The mount point
# $2: The type of file system
# $3: The additional mount options
make_fstab_given_partition_line() {
	local _mount_point="$1" _type="$2" _additional_mount_options="$3"
	test -z "$_additional_mount_options" || _additional_mount_options=",$_additional_mount_options"
	printf "%s     %s     %s     rw%s     0 0\n" "$PARTITION" "$_mount_point" "$_type" "$_additional_mount_options" >> /etc/fstab
}

# $1: The mount point
make_fstab_correct_partition_line() {
	make_fstab_given_partition_line "$1" "ext2" "nodev,noexec,nosuid"
}

make_fstab_bind_partition_line() {
	make_fstab_given_partition_line "$1" "none" "nodev,noexec,nosuid,bind"
}

# $1: The mount point
mount_partition() {
	mkdir -p "$1"
	mount --target "$1"
}

mount_bind_partition() {
	mkdir -p "$1"
	mount -B "$PARTITION" "$1"
}

# $1: The path to umount and remove from /etc/fstab
clean_up_partition() {
    path="$1"
    escaped_path=${path//$'/'/$'\/'}
    sed -i "/${escaped_path}/d" /etc/fstab
    umount ${path} || true  # no problem if not mounted
}
