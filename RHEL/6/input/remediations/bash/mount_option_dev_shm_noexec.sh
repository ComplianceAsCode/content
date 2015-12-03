# platform = Red Hat Enterprise Linux 6

# Load /etc/fstab's /dev/shm row into DEV_SHM_FSTAB variable separating start &
# end of the filesystem mount options (4-th field) with the '#' character
DEV_SHM_FSTAB=$(sed -n "s/\(.*[[:space:]]\+\/dev\/shm[[:space:]]\+tmpfs[[:space:]]\+\)\([^[:space:]]\+\)/\1#\2#/p" /etc/fstab)

#Rest of script can trash /etc/fstab if $DEV_SHM_FSTAB is empty, check before continuing.
echo $DEV_SHM_FSTAB | grep -q -P '/dev/shm'
if [ $? -eq 0 ]; then
	# Save the:
	# * 1-th, 2-nd, 3-rd fields into DEV_SHM_HEAD variable
	# * 4-th field into DEV_SHM_OPTS variable, and
	# * 5-th, and 6-th fields into DEV_SHM_TAIL variable
	# splitting DEV_SHM_FSTAB variable value based on the '#' separator
	IFS='#' read DEV_SHM_HEAD DEV_SHM_OPTS DEV_SHM_TAIL <<< "$DEV_SHM_FSTAB"

	# Replace occurrence of 'defaults' key with the actual list of mount options
	# for Red Hat Enterprise Linux 6
	DEV_SHM_OPTS=${DEV_SHM_OPTS//defaults/rw,suid,dev,exec,auto,nouser,async,relatime}

	# 'exec' option (not prefixed with 'no') present in the list?
	echo $DEV_SHM_OPTS | grep -q -P '(?<!no)exec'
	if [ $? -eq 0 ]
	then
	        # 'exec' option found, replace with 'noexec'
	        DEV_SHM_OPTS=${DEV_SHM_OPTS//exec/noexec}
	fi

	# at least one 'noexec' present in the options list?
	echo $DEV_SHM_OPTS | grep -q -v 'noexec'
	if [ $? -eq 0 ]
	then
	        # 'noexec' not found yet, append it
	        DEV_SHM_OPTS="$DEV_SHM_OPTS,noexec"
	fi

	# DEV_SHM_OPTS now contains final list of mount options. Replace original form of /dev/shm row
	# in /etc/fstab with the corrected version
	sed -i "s#${DEV_SHM_HEAD}\(.*\)${DEV_SHM_TAIL}#${DEV_SHM_HEAD}${DEV_SHM_OPTS}${DEV_SHM_TAIL}#" /etc/fstab

fi
