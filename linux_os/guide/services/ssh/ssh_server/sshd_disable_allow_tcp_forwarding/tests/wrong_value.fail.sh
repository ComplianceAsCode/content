#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^AllowTcpForwarding" /etc/ssh/sshd_config; then
	sed -i "s/^AllowTcpForwarding.*/AllowTcpForwarding yes/" /etc/ssh/sshd_config
else
	echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config
fi
