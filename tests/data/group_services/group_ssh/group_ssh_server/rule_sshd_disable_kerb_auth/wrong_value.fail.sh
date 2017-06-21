#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

if grep -q "^KerberosAuthentication" /etc/ssh/sshd_config; then
	sed -i "s/^KerberosAuthentication.*/KerberosAuthentication yes/" /etc/ssh/sshd_config
else
	echo "KerberosAuthentication yes" >> /etc/ssh/sshd_config
fi
