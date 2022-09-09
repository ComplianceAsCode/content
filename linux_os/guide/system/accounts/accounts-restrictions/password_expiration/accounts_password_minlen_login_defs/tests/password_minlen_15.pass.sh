#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8,multi_platform_fedora

if grep -q "^PASS_MIN_LEN" /etc/login.defs; then
	sed -i "s/^PASS_MIN_LEN.*/PASS_MIN_LEN 15/" /etc/login.defs
else
	echo "PASS_MIN_LEN 15" >> /etc/login.defs
fi
