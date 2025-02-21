# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

# root is default on Ubuntu 24.04
username="root"

if [[ -d /var/log/sssd ]]; then
  find -L /var/log/sssd/ ! -user root ! -user sssd -type f -exec chown $username {} \;
fi
