#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_common

yum install -y audit

NUM_LOGS_REGEX="^num_logs[[:space:]]*=.*$"
if grep -q "$NUM_LOGS_REGEX" /etc/audit/auditd.conf; then
        sed -i "s/^num_logs[[:space:]]=.*$/num_logs = 5/" /etc/audit/auditd.conf
else
        echo "num_logs = 5" >> /etc/audit/auditd.conf
fi
