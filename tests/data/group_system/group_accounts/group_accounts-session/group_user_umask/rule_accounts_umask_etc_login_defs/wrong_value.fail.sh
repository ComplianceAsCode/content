#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^UMASK" /etc/login.defs; then
	sed -i "s/^UMASK.*/UMASK 027/" /etc/login.defs
else
	echo "UMASK 027" >> /etc/login.defs
fi
