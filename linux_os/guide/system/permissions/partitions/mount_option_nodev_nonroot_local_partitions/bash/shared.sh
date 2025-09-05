# platform = multi_platform_all

MOUNT_OPTION="nodev"
# Create array of local non-root partitions
readarray -t partitions_records < <(findmnt --mtab --raw --evaluate | grep "^/\w" | grep "\s/dev/\w")

for partition_record in "${partitions_records[@]}"; do
    # Get all important information for fstab
    mount_point="$(echo ${partition_record} | cut -d " " -f1)"
    device="$(echo ${partition_record} | cut -d " " -f2)"
    device_type="$(echo ${partition_record} | cut -d " " -f3)"
    # device and device_type will be used only in case when the device doesn't have fstab record
    {{{ bash_ensure_mount_option_in_fstab("$mount_point", "$MOUNT_OPTION", "$device", "$device_type") }}}
    {{{ bash_ensure_partition_is_mounted("$mount_point") }}}
done
