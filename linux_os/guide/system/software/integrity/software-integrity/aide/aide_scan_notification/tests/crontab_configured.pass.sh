#!/bin/bash
# packages = aide,crontabs

# configured in crontab
echo '0 5 * * * root /usr/sbin/aide  --check | /bin/mail -s "SSG Test Suite - AIDE Integrity Check" admin@ssgtestsuite' >> /etc/crontab
