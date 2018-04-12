#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_common

yum install -y audit

NUM_LOGS_REGEX="^num_logs[[:space:]]*=.*$"
if grep -q "$NUM_LOGS_REGEX" /etc/audit/auditd.conf; then
        sed -i "s/$NUM_LOGS_REGEX/num_logs = 1/" /etc/audit/auditd.conf
else
        echo "num_logs = 1" >> /etc/audit/auditd.conf
fi
