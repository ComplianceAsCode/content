#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^HostbasedAuthentication" /etc/ssh/sshd_config; then
	sed -i "s/^HostbasedAuthentication.*/HostbasedAuthentication no/" /etc/ssh/sshd_config
else
	echo "HostbasedAuthentication no" >> /etc/ssh/sshd_config
fi
