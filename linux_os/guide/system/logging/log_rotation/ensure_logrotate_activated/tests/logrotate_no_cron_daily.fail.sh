#!/bin/bash

# fix logrotate config
sed -i "s/weekly/daily/" /etc/logrotate.conf

# remove default for cron.daily
rm /etc/cron.daily/logrotate
