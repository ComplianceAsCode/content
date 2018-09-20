# platform = multi_platform_rhel,multi_platform_fedora

. /usr/share/scap-security-guide/remediation_functions

# Delete particular /etc/fstab's row if /var/tmp is already configured to
# represent a mount point (for some device or filesystem other than /tmp)
if grep -q -P '.*\/var\/tmp.*' /etc/fstab
then
  sed -i '/.*\/var\/tmp.*/d' /etc/fstab
fi
umount /var/tmp

# Bind-mount /var/tmp to /tmp via /etc/fstab (preserving the /etc/fstab form)
printf "%-24s%-24s%-8s%-32s%-3s\n" "/tmp" "/var/tmp" "none" "rw,nodev,noexec,nosuid,bind" "0 0" >> /etc/fstab

mkdir -p /var/tmp
mount -B /tmp /var/tmp
