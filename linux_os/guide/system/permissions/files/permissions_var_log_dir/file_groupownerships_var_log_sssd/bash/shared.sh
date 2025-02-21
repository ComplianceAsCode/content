# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

# root is default on Ubuntu 24.04
group="root"

if [[ -d /var/log/sssd ]]; then
  find -L /var/log/sssd/ ! -group root ! -group sssd -type f -exec chgrp $group {} \;
fi
