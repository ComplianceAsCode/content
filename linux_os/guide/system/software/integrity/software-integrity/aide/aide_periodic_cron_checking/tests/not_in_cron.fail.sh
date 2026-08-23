#!/bin/bash
# packages = aide,crontabs,cronie
{{%- if product == 'ubuntu2404' %}}
# platform = Not Applicable
{{%- endif %}}

# aide installs automatically a file that is periodically run on /etc/cron.daily/aide
rm -f /etc/cron.daily/aide

crontab -u root -r || true
