#!/bin/bash
# packages = openssh-7.4p1 openssh-clients-7.4p1 openssh-server-7.4p1
#

if grep -q "^Compression" /etc/ssh/sshd_config; then
	sed -i "s/^Compression.*/Compression yes/" /etc/ssh/sshd_config
else
	echo "Compression yes" >> /etc/ssh/sshd_config
fi
