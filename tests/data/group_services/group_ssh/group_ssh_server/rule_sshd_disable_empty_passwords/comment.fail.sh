#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^PermitEmptyPasswords" /etc/ssh/sshd_config; then
	sed -i "s/^PermitEmptyPasswords.*/# PermitEmptyPasswords yes/" /etc/ssh/sshd_config
else
	echo "# PermitEmptyPasswords yes" >> /etc/ssh/sshd_config
fi
