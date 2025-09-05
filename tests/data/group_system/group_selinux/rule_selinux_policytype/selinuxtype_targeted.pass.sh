#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S, xccdf_org.ssgproject.content_profile_ospp

SELINUX_FILE='/etc/selinux/config'

if grep -s '^[[:space:]]*SELINUXTYPE' $SELINUX_FILE; then
	sed -i 's/^\([[:space:]]*SELINUXTYPE[[:space:]]*=[[:space:]]*\).*/\1targeted/' $SELINUX_FILE
else
	echo 'SELINUXTYPE=targeted' >> $SELINUX_FILE
fi
