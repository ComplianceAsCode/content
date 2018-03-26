# platform = multi_platform_rhel, multi_platform_fedora

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

populate var_removable_partition

ensure_mount_option_in_fstab "$var_removable_partition" noexec

mount -o remount "$var_removable_partition"
