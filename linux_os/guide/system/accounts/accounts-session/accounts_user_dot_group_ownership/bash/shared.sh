# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

awk -F: '{if ($4 >= {{{ gid_min }}} && $4 != {{{ nobody_gid }}}) print $4":"$6}' /etc/passwd | while IFS=: read -r gid home; do find "$home" -maxdepth 1 -name "\.[^.]*" -exec chgrp -f $gid "{}" \;; done
