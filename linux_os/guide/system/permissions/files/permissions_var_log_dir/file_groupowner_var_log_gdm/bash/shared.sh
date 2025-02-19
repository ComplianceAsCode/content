# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

if getent group "gdm" >/dev/null 2>&1; then
    group="gdm"
else
    group="root"
fi

find -L /var/log/ -maxdepth 1 ! -group root ! -group gdm -type d -regextype posix-extended -name 'gdm' -exec chgrp $group {} \;
