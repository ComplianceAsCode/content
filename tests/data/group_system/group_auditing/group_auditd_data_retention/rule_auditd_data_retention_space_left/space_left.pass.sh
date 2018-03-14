#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = bash

if grep -q "^space_left[[:space:]]*= " /etc/audit/auditd.conf; then
	sed -i "s/^space_left = .*$/space_left = 100/" /etc/audit/auditd.conf
else
	echo "space_left = 100" >> /etc/audit/auditd.conf
fi
