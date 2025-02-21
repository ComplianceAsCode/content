# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

if getent group "systemd-journal" >/dev/null 2>&1; then
    group="systemd-journal"
else
    group="root"
fi

find -L /var/log/ ! -group root ! -group systemd-journal -type f \
    -regextype posix-extended -regex ".*\.journal[~]?" -exec chgrp $group {} \;
