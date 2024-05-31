#!/bin/bash
# packages = aide,crontabs

# aide installs automatically a file that is periodically run on /etc/cron.daily/aide
rm -f /etc/cron.daily/aide

echo '21    21    1    *    *    root    {{{ aide_bin_path }}} --check &>/dev/null' >> /etc/crontab
