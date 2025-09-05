#!/bin/bash

# fix logrotate config
sed -i "s/weekly/daily/" /etc/logrotate.conf

# default for cron.daily for RHEL7 is already correct
