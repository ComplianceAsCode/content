#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = bash

SPACE_LEFT_REGEX="^space_left[[:space:]]*=.*$"
if grep -q "$SPACE_LEFT_REGEX" /etc/audit/auditd.conf; then
	sed -i "s/$SPACE_LEFT_REGEX/space_left = 100/" /etc/audit/auditd.conf
else
	echo "space_left = 100" >> /etc/audit/auditd.conf
fi
