#!/bin/bash
# packages = aide,cronie

# configured in crontab
echo '0 5 * * * root /usr/sbin/aide  --check | /bin/mail -s "SSG Test Suite - AIDE Integrity Check" admin@ssgtestsuite' >> /var/spool/cron/root
