# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

# root is default on Ubuntu 24.04
group="root"

find -L /var/log/ -maxdepth 1 ! -group root ! -group adm -type d -regextype posix-extended -name 'apt' -exec chgrp $group {} \;
