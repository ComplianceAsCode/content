#!/bin/bash
#

if grep -q "^PubkeyAuthentication" /etc/ssh/sshd_config; then
	sed -i "s/^PubkeyAuthentication.*/PubkeyAuthentication yes/" /etc/ssh/sshd_config
else
	echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
fi
