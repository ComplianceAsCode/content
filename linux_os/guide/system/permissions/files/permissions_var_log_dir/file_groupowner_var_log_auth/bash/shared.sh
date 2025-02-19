# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

if getent group "adm" >/dev/null 2>&1; then
    group="adm"
else
    group="root"
fi

find -L /var/log/ -maxdepth 1 ! -group root ! -group adm -type f -regextype posix-extended -name 'auth.log' -exec chgrp $group {} \;
