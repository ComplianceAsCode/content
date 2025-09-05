#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^IgnoreRhosts" /etc/ssh/sshd_config; then
	sed -i "s/^IgnoreRhosts.*/IgnoreRhosts yes/" /etc/ssh/sshd_config
else
	echo "IgnoreRhosts yes" >> /etc/ssh/sshd_config
fi
