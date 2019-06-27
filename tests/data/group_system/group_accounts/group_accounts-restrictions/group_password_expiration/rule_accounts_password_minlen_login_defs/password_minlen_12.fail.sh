#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp
# platform = multi_platform_fedora

if grep -q "^PASS_MIN_LEN" /etc/login.defs; then
	sed -i "s/^PASS_MIN_LEN.*/PASS_MIN_LEN 12/" /etc/login.defs
else
	echo "PASS_MIN_LEN 12" >> /etc/login.defs
fi
