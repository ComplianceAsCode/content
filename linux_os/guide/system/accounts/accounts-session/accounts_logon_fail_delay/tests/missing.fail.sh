#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

if grep -q 'FAIL_DELAY' /etc/login.defs; then
	sed -i '/^.*FAIL_DELAY.*/d' /etc/login.defs
fi
