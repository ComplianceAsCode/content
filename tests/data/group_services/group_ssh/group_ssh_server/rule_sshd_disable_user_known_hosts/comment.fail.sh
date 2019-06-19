#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^IgnoreUserKnownHosts" /etc/ssh/sshd_config; then
	sed -i "s/^IgnoreUserKnownHosts.*/# IgnoreUserKnownHosts no/" /etc/ssh/sshd_config
else
	echo "# IgnoreUserKnownHosts no" >> /etc/ssh/sshd_config
fi
