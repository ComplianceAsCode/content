#!/bin/bash
# profiles = C2S, ospp
# remediation = none

SELINUX_FILE='/etc/selinux/config'

if grep -s '^[[:space:]]*SELINUX' $SELINUX_FILE; then
	sed -i 's/^\([[:space:]]*SELINUX[[:space:]]*=[[:space:]]*\).*/\permissive/' $SELINUX_FILE
else
	echo 'SELINUX=permissive' >> $SELINUX_FILE
fi
