#!/bin/bash

# platform = Oracle Linux 7,Red Hat Enterprise Linux 7

# fix logrotate config
sed -i "s/\(weekly\|monthly\|yearly\)/daily/" /etc/logrotate.conf

# default for cron.daily for RHEL7 is already correct
