# platform = multi_platform_all

MOUNT_OPTION="nodev"
# Create array of local non-root partitions
readarray -t partitions_records < <(findmnt --mtab --raw --evaluate | grep "^/\w" | grep -v "^/proc" | grep "\s/dev/\w")

# Create array of polyinstantiated directories, in case one of them is found in mtab
readarray -t polyinstantiated_dirs < \
    <(grep -oP "^\s*[^#\s]+\s+\S+" /etc/security/namespace.conf | grep -oP "(?<=\s)\S+?(?=/?\$)")

# Define excluded non-local file systems
excluded_fstypes=(
    afs
    autofs
    ceph
    cifs
    smb3
    smbfs
    sshfs
    ncpfs
    ncp
    nfs
    nfs4
    gfs
    gfs2
    glusterfs
    gpfs
    pvfs2
    ocfs2
    lustre
    davfs
    fuse.sshfs
)

for partition_record in "${partitions_records[@]}"; do
    # Get all important information for fstab
    mount_point="$(echo "${partition_record}" | cut -d " " -f1)"
    device="$(echo "${partition_record}" | cut -d " " -f2)"
    device_type="$(echo "${partition_record}" | cut -d " " -f3)"

    # Skip polyinstantiated directories
    if printf '%s\0' "${polyinstantiated_dirs[@]}" | grep -qxzF "$mount_point"; then
        continue
    fi

    # Skip any non-local filesystem
    for excluded_fstype in "${excluded_fstypes[@]}"; do
        if [[ "$device_type" == "$excluded_fstype" ]]; then
            # jump out of both loops and move to next partition_record
            continue 2
        fi
    done

    # If we reach here, it's a local, non-root partition that isn't excluded.
    {{{ bash_ensure_mount_option_in_fstab("$mount_point",
                                          "$MOUNT_OPTION",
                                          "$device",
                                          "$device_type") | indent(4) }}}
    {{{ bash_ensure_partition_is_mounted("$mount_point")     | indent(4) }}}
done

# Remediate unmounted /etc/fstab entries
sed -i -E '/nodev/! s;^\s*(/dev/\S+|UUID=\S+)\s+(/\w\S*)\s+(\S+)\s+(\S+)(.*)$;\1 \2 \3 \4,nodev \5;' /etc/fstab
