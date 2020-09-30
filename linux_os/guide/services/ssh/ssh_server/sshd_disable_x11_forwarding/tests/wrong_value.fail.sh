#!/bin/bash
#

if grep -q "^X11Forwarding" /etc/ssh/sshd_config; then
	sed -i "s/^X11Forwarding.*/X11Forwarding yes/" /etc/ssh/sshd_config
else
	echo "X11Forwarding yes" >> /etc/ssh/sshd_config
fi
