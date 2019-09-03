#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8

if grep -q "^PASS_MIN_LEN" /etc/login.defs; then
	sed -i "s/^PASS_MIN_LEN.*/PASS_MIN_LEN 15/" /etc/login.defs
else
	echo "PASS_MIN_LEN 15" >> /etc/login.defs
fi
