# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{% if product in ["sle12", "sle15", "slmicro5"] %}}
awk -F: '{if ($3 >= {{{ uid_min }}} && $3 != {{{ nobody_uid }}}) print $4":"$6}' /etc/passwd | while IFS=: read -r gid home; do find -P "$home" -maxdepth 1 -type f -name "\.[^.]*" -exec chgrp -f --no-dereference -- $gid "{}" \;; done
{{% else %}}
awk -F: '{if ($4 >= {{{ gid_min }}} && $4 != {{{ nobody_gid }}}) print $4":"$6}' /etc/passwd | while IFS=: read -r gid home; do find -P "$home" -maxdepth 1 -type f -name "\.[^.]*" -exec chgrp -f --no-dereference -- $gid "{}" \;; done
{{% endif %}}
