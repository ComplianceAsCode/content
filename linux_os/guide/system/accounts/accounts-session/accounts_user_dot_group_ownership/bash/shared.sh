# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

awk -F':' '{ if ($3 >= {{{ uid_min }}} && $3 != 65534) system("chgrp -f " $3" "$6"/.[^\.]?*") }' /etc/passwd
