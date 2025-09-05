#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

if grep -q 'FAIL_DELAY' /etc/login.defs; then
	sed -i 's/^.*FAIL_DELAY.*/FAIL_DELAY 4/' /etc/login.defs
else
	echo 'FAIL_DELAY 4' >> /etc/login.defs
fi
