# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low
find -L /var/log/ -maxdepth 1 ! -owner root ! -owner sssd -type d -regextype posix-extended -name 'sssd' -exec chown sssd {} \;
