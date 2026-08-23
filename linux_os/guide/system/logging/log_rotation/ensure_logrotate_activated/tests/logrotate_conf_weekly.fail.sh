#!/bin/bash

LOGROTATE_CONF_FILE="/etc/logrotate.conf"
{{% if product in [ 'sle16', 'slmicro6' ] %}}
{{{ bash_copy_distro_defaults('/usr/etc/logrotate.conf', "${LOGROTATE_CONF_FILE}") }}}
{{% endif %}}
sed -i "s/daily/weekly/" "${LOGROTATE_CONF_FILE}"
