#!/bin/bash
# packages = aide,cronie

# configured in crontab
echo '0 5 * * * root /usr/sbin/aide  --check | /bin/mail -s "Automatus - AIDE Integrity Check" admin@automatus' >> /var/spool/cron/root
