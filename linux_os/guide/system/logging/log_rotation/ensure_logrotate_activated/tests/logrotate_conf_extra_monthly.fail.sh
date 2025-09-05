#!/bin/bash

# packages = logrotate,crontabs

sed -i "s/weekly/daily/g" /etc/logrotate.conf
echo "monthly" >> /etc/logrotate.conf
