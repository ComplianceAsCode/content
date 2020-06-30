#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^TMOUT=" /etc/profile.d/tmout.sh; then
	sed -i "s/^TMOUT=.*/TMOUT=60/" /etc/profile.d/tmout.sh
else
	echo "TMOUT=60" >> /etc/profile.d/tmout.sh
fi
if grep -q "^TMOUT=" /etc/profile ; then
    sed -i "/^TMOUT=.*/d" /etc/profile
fi
