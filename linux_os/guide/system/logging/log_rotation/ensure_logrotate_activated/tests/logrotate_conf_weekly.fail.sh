#!/bin/bash

{{% if product == 'sle16' %}}
LOGROTATE_CONF_FILE="/usr/etc/logrotate.conf"
{{% else %}}
LOGROTATE_CONF_FILE="/etc/logrotate.conf"
{{% endif %}}
sed -i "s/daily/weekly/" "${LOGROTATE_CONF_FILE}"
