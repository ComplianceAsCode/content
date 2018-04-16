#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^UMASK" /etc/login.defs; then
	sed -i "s/^UMASK.*/umask 077/" /etc/login.defs
else
	echo "umask 077" >> /etc/login.defs
fi
