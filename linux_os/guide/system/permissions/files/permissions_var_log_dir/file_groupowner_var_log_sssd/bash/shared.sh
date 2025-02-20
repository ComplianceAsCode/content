# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

if getent group "sssd" >/dev/null 2>&1; then
    group="sssd"
else
    group="root"
fi

find -L /var/log/ -maxdepth 1 ! -group root ! -group sssd -type d -regextype posix-extended -name 'sssd' -exec chgrp $group {} \;
