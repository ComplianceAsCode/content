# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

awk -F: '{if ($3 >= {{{ uid_min }}} && $3 != {{{ nobody_uid }}}) print $3":"$6}' /etc/passwd | while IFS=: read -r uid home; do find -P "$home" -maxdepth 1 -type f -name "\.[^.]*" -exec chown -f --no-dereference -- $uid "{}" \;; done
