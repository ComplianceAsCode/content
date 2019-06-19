#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^PermitRootLogin" /etc/ssh/sshd_config; then
	sed -i "s/^PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config
else
	echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
fi
