#!/bin/bash
#

if grep -q "^KerberosAuthentication" /etc/ssh/sshd_config; then
	sed -i "s/^KerberosAuthentication.*/KerberosAuthentication no/" /etc/ssh/sshd_config
else
	echo "KerberosAuthentication no" >> /etc/ssh/sshd_config
fi
