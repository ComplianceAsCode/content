#!/bin/bash
# packages = aide,crontabs

# configured in crontab
echo '0 5 * * * root /usr/sbin/aide  --check' >> /etc/crontab
