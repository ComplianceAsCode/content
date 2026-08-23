# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

for user in $(awk -F':' '{ if ($3 >= {{{ uid_min }}} && $3 != {{{ nobody_uid }}} && $6 != "/") print $1 }' /etc/passwd); do
    home_dir=$(getent passwd $user | cut -d: -f6)
    # Only update the ownership when necessary. This will avoid changing the inode timestamp
    # when the owner is already defined as expected, therefore not impacting in possible integrity
    # check systems that also check inodes timestamps.
    find $home_dir -not -user $user -exec chown -f --no-dereference $user {} \;
done
