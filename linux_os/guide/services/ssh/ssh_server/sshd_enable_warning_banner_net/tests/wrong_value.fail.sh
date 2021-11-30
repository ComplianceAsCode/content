#!/bin/bash
#

if grep -q "^Banner" /etc/ssh/sshd_config; then
	sed -i "s/^Banner.*/Banner none/" /etc/ssh/sshd_config
else
	echo "Banner none" >> /etc/ssh/sshd_config
fi
