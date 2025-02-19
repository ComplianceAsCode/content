# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

if getent group "utmp" >/dev/null 2>&1; then
    group="utmp"
else
    group="root"
fi

find -L /var/log/ -maxdepth 1 ! -group root ! -group utmp -type f -regextype posix-extended -regex '.*lastlog(\.[^\/]+)?$' -exec chgrp $group {} \;
