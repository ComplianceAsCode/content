#!/bin/bash

# platform = Red Hat Enterprise Linux 7

# fix logrotate config
sed -i "s/\(weekly\|monthly\|yearly\)/daily/" /etc/logrotate.conf

# default for cron.daily for RHEL7 is already correct
