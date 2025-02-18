# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low
find -L /var/log/ -maxdepth 1 ! -group root ! -group gdm -type d -regextype posix-extended -name 'gdm3' -exec chgrp gdm {} \;
