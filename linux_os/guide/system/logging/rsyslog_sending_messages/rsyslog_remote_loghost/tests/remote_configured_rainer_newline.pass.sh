#!/bin/bash
# packages = rsyslog

CONF_FILE="/etc/rsyslog.conf"
LOGHOST_LINE=$'*.* action(type="omfwd"\nqueue.type="linkedlist"\nqueue.filename="example_fwd"\naction.resumeRetryCount="-1"\nqueue.saveOnShutdown="on"\ntarget="192.168.122.1"\nport="30514"\nprotocol="tcp")'

if grep -q "^\*\.\*" "$CONF_FILE"; then
	sed -i "s|^\*\.\*.*|$LOGHOST_LINE|" "$CONF_FILE"
else
	echo "$LOGHOST_LINE" >> "$CONF_FILE"
fi
