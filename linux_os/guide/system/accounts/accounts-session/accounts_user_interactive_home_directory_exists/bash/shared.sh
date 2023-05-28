# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

for user in $(awk -F':' '{ if ($3 >= {{{ uid_min }}} && $3 != {{{ nobody_uid }}}) print $1}' /etc/passwd); do
    mkhomedir_helper $user 0077;
done
