#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^Banner" /etc/ssh/sshd_config; then
	sed -i "s|^Banner.*|# Banner /etc/issue/|" /etc/ssh/sshd_config
else
	echo "# Banner /etc/issue" >> /etc/ssh/sshd_config
fi
