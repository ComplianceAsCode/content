#!/bin/bash

# packages = logrotate,crontabs

# fix logrotate config
sed -i "s/weekly/daily/" /etc/logrotate.conf

# remove default for cron.daily
rm -f /etc/cron.daily/logrotate
