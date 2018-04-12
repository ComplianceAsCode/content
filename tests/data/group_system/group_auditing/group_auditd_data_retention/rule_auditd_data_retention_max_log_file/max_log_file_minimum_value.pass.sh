#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_common

yum install -y audit

MAX_LOG_FILE="^max_log_file[[:space:]]*=.*$"
if grep -q "$MAX_LOG_FILE" /etc/audit/auditd.conf; then
        sed -i "s/$MAX_LOG_FILE/max_log_file = 6/" /etc/audit/auditd.conf
else
        echo "max_log_file = 6" >> /etc/audit/auditd.conf
fi
