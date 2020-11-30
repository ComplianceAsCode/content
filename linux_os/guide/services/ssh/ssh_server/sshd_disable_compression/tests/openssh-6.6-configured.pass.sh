#!/bin/bash
#
# variables = var_sshd_disable_compression=no

# Test targeted to RHEL 7.4
yum downgrade -y openssh-6.6.1p1 openssh-clients-6.6.1p1 openssh-server-6.6.1p1

if grep -q "^Compression" /etc/ssh/sshd_config; then
	sed -i "s/^Compression.*/Compression no/" /etc/ssh/sshd_config
else
	echo "Compression no" >> /etc/ssh/sshd_config
fi
