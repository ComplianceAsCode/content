#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^RhostsRSAAuthentication" /etc/ssh/sshd_config; then
	sed -i "s/^RhostsRSAAuthentication.*/RhostsRSAAuthentication yes/" /etc/ssh/sshd_config
else
	echo "RhostsRSAAuthentication yes" >> /etc/ssh/sshd_config
fi
