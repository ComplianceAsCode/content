# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

FILTER_NODEV=$(awk '/nodev/ { print $2 }' /proc/filesystems | paste -sd,)

# Do not consider /sysroot partition because it contains only the physical
# read-only root on bootable containers.
PARTITIONS=$(findmnt -n -l -k -it $FILTER_NODEV | awk '{ print $1 }' | grep -v "/sysroot")

for PARTITION in $PARTITIONS; do
  find "${PARTITION}" -xdev -type f -perm -002 -exec chmod o-w {} \; 2>/dev/null
done

# Ensure /tmp is also fixed when tmpfs is used.
if grep "^tmpfs /tmp" /proc/mounts; then
  find /tmp -xdev -type f -perm -002 -exec chmod o-w {} \; 2>/dev/null
fi
