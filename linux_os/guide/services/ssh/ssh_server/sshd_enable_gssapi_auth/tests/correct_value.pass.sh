#!/bin/bash

if grep -q "^GSSAPIAuthentication" /etc/ssh/sshd_config; then
	sed -i "s/^GSSAPIAuthentication.*/GSSAPIAuthentication yes/" /etc/ssh/sshd_config
else
	echo "GSSAPIAuthentication yes" >> /etc/ssh/sshd_config
fi
