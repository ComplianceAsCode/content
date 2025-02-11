# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

awk -F':' '{ if ($3 >= {{{ uid_min }}} && $3 != {{{ nobody_uid }}}) system("find "$6" -maxdepth 1 -name \.[^.]?* -exec chgrp -f "$4" {} \;") }' /etc/passwd
