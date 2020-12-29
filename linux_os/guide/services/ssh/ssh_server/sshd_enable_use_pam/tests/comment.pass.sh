#!/bin/bash
#

if grep -q "^UsePAM" /etc/ssh/sshd_config; then
	sed -i "s/^UsePAM.*/# UsePAM yes/" /etc/ssh/sshd_config
else
	echo "# UsePAM yes" >> /etc/ssh/sshd_config
fi
