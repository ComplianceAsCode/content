# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low
find -L /var/log/ -maxdepth 1 ! -group root ! -group systemd-journal -type f -regextype posix-extended -regex ".*\.journal[~]?" -exec chgrp systemd-journal {} \;
