#!/bin/bash

# packages = logrotate,crontabs

sed -i "/^\s*(daily|weekly|monthly|yearly)/d" /etc/logrotate.conf
rm -f /etc/cron.daily/logrotate
