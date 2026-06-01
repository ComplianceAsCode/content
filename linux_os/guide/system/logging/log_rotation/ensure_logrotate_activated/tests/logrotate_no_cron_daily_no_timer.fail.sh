#!/bin/bash

# packages = logrotate,crontabs

LOGROTATE_CONF_FILE="/etc/logrotate.conf"

{{% if product in [ 'sle16', 'slmicro6' ] %}}
{{{ bash_copy_distro_defaults('/usr/etc/logrotate.conf', "${LOGROTATE_CONF_FILE}") }}}
{{% endif %}}

# disable the timer
systemctl disable logrotate.timer || true

# fix logrotate config
sed -i "s/weekly/daily/" "${LOGROTATE_CONF_FILE}"

# remove default for cron.daily
rm -f /etc/cron.daily/logrotate
