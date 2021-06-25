#!/bin/bash
#
# packages = aide

# aide installs automatically a file that is periodically run on /etc/cron.daily/aide
rm -f /etc/cron.daily/aide

echo '21    21    1    *    *    root    /usr/sbin/aide --check &>/dev/null' >> /etc/crontab
