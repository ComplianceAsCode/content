#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

if grep -q "^TMOUT" /etc/profile; then
	sed -i "s/^TMOUT.*/TMOUT=100/" /etc/profile
else
	echo "TMOUT=100" >> /etc/profile
fi
