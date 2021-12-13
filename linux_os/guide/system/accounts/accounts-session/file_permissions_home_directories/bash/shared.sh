# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

for home_dir in $(awk -F':' '{ if ($4 >= {{{ uid_min }}} && $4 != 65534) print $6 }' /etc/passwd); do
    # Only update the permissions when necessary. This will avoid changing the inode timestamp when
    # the permission is already defined as expected, therefore not impacting in possible integrity
    # check systems that also check inodes timestamps.
    find $home_dir -perm /7027 -exec chmod u-s,g-w-s,o=- {} \;
done
