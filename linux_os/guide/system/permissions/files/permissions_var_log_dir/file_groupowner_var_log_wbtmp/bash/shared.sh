# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low
# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

find -L /var/log/ -maxdepth 1 ! -group root ! -group utmp -type f -regextype posix-extended -regex '.*(b|w)tmp((\.|-)[^\/]+)?$' -exec chgrp utmp {} \;
