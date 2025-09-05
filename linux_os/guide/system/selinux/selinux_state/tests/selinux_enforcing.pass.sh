#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S, xccdf_org.ssgproject.content_profile_ospp

SELINUX_FILE='/etc/selinux/config'

if grep -s '^[[:space:]]*SELINUX' $SELINUX_FILE; then
	sed -i 's/^\([[:space:]]*SELINUX[[:space:]]*=[[:space:]]*\).*/\1enforcing/' $SELINUX_FILE
else
	echo 'SELINUX=enforcing' >> $SELINUX_FILE
fi
