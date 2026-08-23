#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S, xccdf_org.ssgproject.content_profile_ospp
# remediation = none

SELINUX_FILE='/etc/selinux/config'
touch "$SELINUX_FILE"

if grep -s '^[[:space:]]*SELINUX' $SELINUX_FILE; then
	sed -i 's/^\([[:space:]]*SELINUX[[:space:]]*=[[:space:]]*\).*/\1permissive/' $SELINUX_FILE
else
	echo 'SELINUX=permissive' >> $SELINUX_FILE
fi
