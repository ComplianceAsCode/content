#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^KerberosAuthentication" /etc/ssh/sshd_config; then
	sed -i "s/^KerberosAuthentication.*/KerberosAuthentication no/" /etc/ssh/sshd_config
else
	echo "KerberosAuthentication no" >> /etc/ssh/sshd_config
fi
