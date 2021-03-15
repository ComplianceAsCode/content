#!/bin/bash

# packages = logrotate,crontabs

sed -i "/^daily/d" /etc/logrotate.conf
rm -f /etc/cron.daily/logrotate
