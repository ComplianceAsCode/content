# platform = multi_platform_rhel, multi_platform_fedora

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

populate var_removable_partition

NEW_OPT="nodev"

if [ $(grep "$var_removable_partition" /etc/fstab | grep -c "$NEW_OPT" ) -eq 0 ]; then
  MNT_OPTS=$(grep "$var_removable_partition" /etc/fstab | awk '{print $4}')
  sed -i "s|\($var_removable_partition.*${MNT_OPTS}\)|\1,${NEW_OPT}|" /etc/fstab
fi
