#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

if grep -q "^StrictModes" /etc/ssh/sshd_config; then
	sed -i "s/^StrictModes.*/StrictModes no/" /etc/ssh/sshd_config
else
	echo "StrictModes no" >> /etc/ssh/sshd_config
fi
