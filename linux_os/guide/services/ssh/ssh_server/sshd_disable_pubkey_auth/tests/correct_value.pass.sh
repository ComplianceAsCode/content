#!/bin/bash
#

if grep -q "^PubkeyAuthentication" /etc/ssh/sshd_config; then
	sed -i "s/^PubkeyAuthentication.*/PubkeyAuthentication no/" /etc/ssh/sshd_config
else
	echo "PubkeyAuthentication no" >> /etc/ssh/sshd_config
fi
