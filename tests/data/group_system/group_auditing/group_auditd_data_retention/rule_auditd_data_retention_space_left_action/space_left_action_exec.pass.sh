#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = bash

yum install -y audit

SPACE_LEFT_ACTION_REGEX="^space_left_action[[:space:]]*=.*$"
if grep -q "$SPACE_LEFT_ACTION_REGEX" /etc/audit/auditd.conf; then
        sed -i "s/$SPACE_LEFT_ACTION_REGEX/space_left_action = exec \/path-to-script/" /etc/audit/auditd.conf
else
        echo "space_left_action = exec /path-to-script" >> /etc/audit/auditd.conf
fi
