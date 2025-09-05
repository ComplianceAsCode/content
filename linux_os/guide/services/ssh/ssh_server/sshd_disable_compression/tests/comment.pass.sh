#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^Compression" /etc/ssh/sshd_config; then
	sed -i "s/^Compression.*/# Compression no/" /etc/ssh/sshd_config
else
	echo "# Compression no" >> /etc/ssh/sshd_config
fi
