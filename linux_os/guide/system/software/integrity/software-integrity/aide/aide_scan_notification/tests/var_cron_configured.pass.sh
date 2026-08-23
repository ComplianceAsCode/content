#!/bin/bash
# packages = aide,cronie

# configured in crontab
echo '0 5 * * * root {{{ aide_bin_path }}}  --check | /bin/mail -s "Automatus - AIDE Integrity Check" admin@automatus' >> /var/spool/cron/root
