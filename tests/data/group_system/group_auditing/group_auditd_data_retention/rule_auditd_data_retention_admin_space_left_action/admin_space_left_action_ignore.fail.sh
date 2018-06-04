#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S
# remediation = bash

yum install -y audit

ADMIN_SPACE_LEFT_ACTION_REGEX="^admin_space_left_action[[:space:]]*=.*$"
if grep -q "$ADMIN_SPACE_LEFT_ACTION_REGEX" /etc/audit/auditd.conf; then
    sed -i "s/$ADMIN_SPACE_LEFT_ACTION_REGEX/admin_space_left_action = ignore/" /etc/audit/auditd.conf
else
    echo "admin_space_left_action = ignore" >> /etc/audit/auditd.conf
fi
