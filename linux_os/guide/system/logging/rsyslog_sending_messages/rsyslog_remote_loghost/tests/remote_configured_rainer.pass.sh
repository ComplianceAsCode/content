#!/bin/bash
# packages = rsyslog

CONF_FILE="/etc/rsyslog.conf"
LOGHOST_LINE='*.* action(type="omfwd" queue.type="linkedlist" queue.filename="example_fwd" action.resumeRetryCount="-1" queue.saveOnShutdown="on" target="192.168.122.1" port="30514" protocol="tcp")'

if grep -q "^\*\.\*" "$CONF_FILE"; then
	sed -i "s|^\*\.\*.*|$LOGHOST_LINE|" "$CONF_FILE"
else
	echo "$LOGHOST_LINE" >> "$CONF_FILE"
fi
