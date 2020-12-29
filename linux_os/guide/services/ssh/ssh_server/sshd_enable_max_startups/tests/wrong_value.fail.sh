#!/bin/bash
#

if grep -q "^maxstartups" /etc/ssh/sshd_config; then
	sed -i "s/^maxstartups.*/maxstartups yes/" /etc/ssh/sshd_config
else
	echo "maxstartups yes" >> /etc/ssh/sshd_config
fi
