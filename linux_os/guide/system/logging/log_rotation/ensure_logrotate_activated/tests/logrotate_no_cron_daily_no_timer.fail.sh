#!/bin/bash

# packages = logrotate,crontabs

{{% if product == 'sle16' %}}
LOGROTATE_CONF_FILE="/usr/etc/logrotate.conf"
{{% else %}}
LOGROTATE_CONF_FILE="/etc/logrotate.conf"
{{% endif %}}

# disable the timer
systemctl disable logrotate.timer || true

# fix logrotate config
sed -i "s/weekly/daily/" "${LOGROTATE_CONF_FILE}"

# remove default for cron.daily
rm -f /etc/cron.daily/logrotate
