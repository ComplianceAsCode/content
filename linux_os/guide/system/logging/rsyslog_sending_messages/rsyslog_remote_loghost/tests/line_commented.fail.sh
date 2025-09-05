#!/bin/bash
# packages = rsyslog

CONF_FILE="/etc/rsyslog.conf"
LOGHOST_LINE="*.* @@192.168.122.1:5000"

if grep -q "^\*\.\*" "$CONF_FILE"; then
	sed -i "s|^\(\*\.\*.*\)|# \1|" "$CONF_FILE"
else
	echo "# $LOGHOST_LINE" >> "$CONF_FILE"
fi
