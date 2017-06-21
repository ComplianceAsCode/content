#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

if grep -q "^Compression" /etc/ssh/sshd_config; then
	sed -i "s/^Compression.*/Compression yes/" /etc/ssh/sshd_config
else
	echo "Compression yes" >> /etc/ssh/sshd_config
fi
