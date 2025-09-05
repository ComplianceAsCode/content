#!/usr/bin/env bash
# platform = Ubuntu 24.04
# check-import = stdout

filter_nodev=$(awk '/nodev/ { print $2 }' /proc/filesystems | paste -sd,)
readarray -t partitions < <(findmnt -n -l -k -it "${filter_nodev}" | awk '{ print $1 }')

# Ensure /tmp is also checked when tmpfs is used.
if grep -Pq "^tmpfs\h+/tmp" /proc/mounts; then
    partitions+=("/tmp")
fi

for partition in "${partitions[@]}"; do
    files=$(find "${partition}" -xdev -type f -nogroup)
    if [[ -n "${files}" ]]; then
        echo -e "Found ungroupowned files:\n${files}"
        exit "${XCCDF_RESULT_FAIL}"
    fi
done

exit "${XCCDF_RESULT_PASS}"
