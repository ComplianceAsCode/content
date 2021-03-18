#!/bin/bash

CONF_FILE="/etc/rsyslog.conf"

declare -a BAD_LINES=("\\\$ModLoad\\s\\+imtcp"
"\\\$InputTCPServerRun.*"
"\\\$ModLoad\\s\\+imudp"
"\\\$UDPServerRun.*"
"\\\$ModLoad\\s\\+imrelp"
"\\\$InputRELPServerRun.*")

for line in "${BAD_LINES[@]}"; do
	sed -i "/$line/d" "$CONF_FILE"
done
