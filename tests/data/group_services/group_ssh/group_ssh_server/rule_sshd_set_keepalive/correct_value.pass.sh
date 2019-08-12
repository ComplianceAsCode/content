#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
SSHD_CONFIG="/etc/ssh/sshd_config"

if grep -q "^ClientAliveCountMax" $SSHD_CONFIG; then
	sed -i "s/^ClientAliveCountMax.*/ClientAliveCountMax 0/" $SSHD_CONFIG
else
	echo "ClientAliveCountMax 0" >> $SSHD_CONFIG
fi
