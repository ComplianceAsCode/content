# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

# root is default on Ubuntu 24.04
group="root"

if [[ -d /var/log/apt ]]; then
  find -L /var/log/apt/ -type f ! -group root ! -group adm -exec chgrp $group {} \;
fi
