#!/bin/bash
#
# packages = aide

# aide installs automatically a file that is periodically run on /etc/cron.daily/aide
rm -f /etc/cron.daily/aide

crontab -u root -r || true
