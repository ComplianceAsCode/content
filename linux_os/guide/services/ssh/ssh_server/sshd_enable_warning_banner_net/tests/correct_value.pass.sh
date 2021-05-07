#!/bin/bash
#

if grep -q "^Banner" /etc/ssh/sshd_config; then
	sed -i "s|^Banner.*|Banner /etc/issue.net|" /etc/ssh/sshd_config
else
	echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
fi
