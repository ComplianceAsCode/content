#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep grep -q "^TMOUT=" /etc/profile.d/tmout.sh; then
	sed -i "/^TMOUT=.*/d" /etc/profile.d/tmout.sh
fi
if grep grep -q "^TMOUT=" /etc/profile ; then
    sed -i "/^TMOUT=.*/d" /etc/profile
fi
