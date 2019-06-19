#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^IgnoreRhosts" /etc/ssh/sshd_config; then
	sed -i "s/^IgnoreRhosts.*/# IgnoreRhosts no/" /etc/ssh/sshd_config
else
	echo "# IgnoreRhosts no" >> /etc/ssh/sshd_config
fi
