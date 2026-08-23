
# $1: Mount device
# $2: Mount point
# $3: Mount options besides ro
function cd_like_fstab_line {
	local _mount_device="$1" _mount_point="$2" _additional_mount_options="$3"
	test -z "$_additional_mount_options" || _additional_mount_options=",$_additional_mount_options"
	printf "%s %s iso9660 ro%s  0 0" "$_mount_device" "$_mount_point" "$_additional_mount_options"
}

# $1: Mount options besides ro
function cdrom_fstab_line {
	cd_like_fstab_line "/dev/cdrom" "/var/cdrom" "$1"
}

# $1: Mount options besides ro
function dvdrom_fstab_line {
	cd_like_fstab_line "/dev/dvd" "/var/dvdrom" "$1"
}

# $1: Mount options besides ro
# $2: Index of the device (optional, 0 is default)
function sata_removable_fstab_line {
	cd_like_fstab_line "/dev/sr${2:-0}" "/var/cdrom" "$1"
}

# $1: Mount options besides rw
# $2: Index of the device (optional, 0 is default)
function floppy_fstab_line {
	test -z "$_additional_mount_options" || _additional_mount_options=",$_additional_mount_options"
	printf "%s %s vfat rw%s  0 0" "/dev/fd${2:-0}" "/var/floppy" "$_additional_mount_options"
}
