# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

for dir in $(awk -F':' '{ if ($3 >= {{{ uid_min }}} && $3 != 65534) print $6}' /etc/passwd); do
    sed -i 's/^\([\s]*umask\s*\)/#\1/g' $dir/.[^\.]?*
done
