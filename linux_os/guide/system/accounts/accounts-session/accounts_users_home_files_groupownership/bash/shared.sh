# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

for user in $(awk -F':' '{ if ($4 >= {{{ gid_min }}} && $4 != 65534) print $1 }' /etc/passwd); do
    home_dir=$(getent passwd $user | cut -d: -f6)
    group=$(getent passwd $user | cut -d: -f4)
    # Only update the group-ownership when necessary. This will avoid changing the inode timestamp
    # when the group is already defined as expected, therefore not impacting in possible integrity
    # check systems that also check inodes timestamps.
    find $home_dir -not -group $group -exec chgrp -f $group {} \;
done
