# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_sle

# Identify local mounts
MOUNT_LIST=$(df --local | awk '{ print $6 }')

# Find file on each listed mount point
for cur_mount in ${MOUNT_LIST}
do
	find ${cur_mount} -xdev -type f -name ".shosts" -exec rm -f {} \;
done
