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

if [[ -d /var/log/gdm3 ]]; then
  find -L /var/log/gdm3/ ! -group root ! -group gdm -type f -exec chgrp $group {} \;
fi
