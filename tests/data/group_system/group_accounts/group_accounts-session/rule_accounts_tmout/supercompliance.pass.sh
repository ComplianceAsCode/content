#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "TMOUT" /etc/profile; then
	sed -i "s/.*TMOUT.*/TMOUT=60/" /etc/profile
else
	echo "TMOUT=60" >> /etc/profile
fi
