#!/bin/bash

# packages = logrotate,crontabs
LOGROTATE_CONF_FILE="/etc/logrotate.conf"
{{% if product in [ 'sle16', 'slmicro6' ] %}}
{{{ bash_copy_distro_defaults('/usr/etc/logrotate.conf', "${LOGROTATE_CONF_FILE}") }}}
{{% endif %}}

sed -i "s/weekly/daily/g" "${LOGROTATE_CONF_FILE}"
echo "monthly" >> "${LOGROTATE_CONF_FILE}"
