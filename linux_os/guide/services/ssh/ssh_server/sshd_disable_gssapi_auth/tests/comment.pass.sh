#!/bin/bash
#

if grep -q "^GSSAPIAuthentication" /etc/ssh/sshd_config; then
	sed -i "s/^GSSAPIAuthentication.*/# GSSAPIAuthentication no/" /etc/ssh/sshd_config
else
	echo "# GSSAPIAuthentication no" >> /etc/ssh/sshd_config
fi
