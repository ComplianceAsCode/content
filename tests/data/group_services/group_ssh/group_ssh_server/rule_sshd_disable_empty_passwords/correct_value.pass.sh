#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^PermitEmptyPasswords" /etc/ssh/sshd_config; then
	sed -i "s/^PermitEmptyPasswords.*/PermitEmptyPasswords no/" /etc/ssh/sshd_config
else
	echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config
fi
