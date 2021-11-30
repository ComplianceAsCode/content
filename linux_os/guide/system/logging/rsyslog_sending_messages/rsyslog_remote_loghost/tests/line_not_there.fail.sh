#!/bin/bash
# packages = rsyslog

CONF_FILE="/etc/rsyslog.conf"
sed -i "/^\*\.\*.*/d" "$CONF_FILE"
