#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^X11Forwarding" /etc/ssh/sshd_config; then
	sed -i "s/^X11Forwarding.*/X11Forwarding no/" /etc/ssh/sshd_config
else
	echo "X11Forwarding no" >> /etc/ssh/sshd_config
fi
