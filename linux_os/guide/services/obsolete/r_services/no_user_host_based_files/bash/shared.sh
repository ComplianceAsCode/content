# platform = Red Hat Virtualization 4,multi_platform_rhel,multi_platform_sle,multi_platform_ol

# Identify local mounts
MOUNT_LIST=$(df --local | awk '{ print $6 }')

# Find file on each listed mount point
for cur_mount in ${MOUNT_LIST}
do
	find ${cur_mount} -xdev -type f -name ".shosts" -exec rm -f {} \;
done
