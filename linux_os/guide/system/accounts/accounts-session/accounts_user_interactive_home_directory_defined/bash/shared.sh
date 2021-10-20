# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

for user in `awk -F':' '{ if ($4 >= {{{ uid_min }}} && $4 != 65534) print $1 }' /etc/passwd`; do
    sed -i "s/\($user:x:[0-9]*:[0-9]*:.*:\).*\(:.*\)$/\1\/home\/$user\2/g" /etc/passwd;
done