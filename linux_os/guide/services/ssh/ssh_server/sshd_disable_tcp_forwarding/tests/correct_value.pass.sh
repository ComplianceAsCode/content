#!/bin/bash
#

if grep -q "^AllowTcpForwarding" /etc/ssh/sshd_config; then
	sed -i "s/^AllowTcpForwarding.*/AllowTcpForwarding no/" /etc/ssh/sshd_config
else
	echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config
fi
