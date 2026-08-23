# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

awk -F':' '{ if ($3 >= {{{ uid_min }}} && $3 != {{{ nobody_uid }}} && $6 != "/") system("chgrp -f " $4" "$6) }' /etc/passwd
