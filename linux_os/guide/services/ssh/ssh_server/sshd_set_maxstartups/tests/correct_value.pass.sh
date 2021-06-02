#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

if grep -q "^MaxStartups" /etc/ssh/sshd_config; then
	sed -i "s/^MaxStartups.*/UsePrivilegeSeparation 10:30:60/" /etc/ssh/sshd_config
else
	echo "MaxStartups 10:30:60" >> /etc/ssh/sshd_config
fi
