#!/bin/bash
#

if grep -q "^UsePAM" /etc/ssh/sshd_config; then
	sed -i "s/^UsePAM.*/UsePAM no/" /etc/ssh/sshd_config
else
	echo "UsePAM no" >> /etc/ssh/sshd_config
fi
