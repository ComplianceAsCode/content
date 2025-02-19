# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

# root is default on Ubuntu 24.04
username="root"

find -L /var/log/ -maxdepth 1 ! -user root ! -user sssd -type d -regextype posix-extended -name 'sssd' -exec chown $username {} \;
