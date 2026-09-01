#!/bin/bash
# packages = audit
# platform = multi_platform_rhel

echo "-a always,exit -F arch=b64 -S execve -F subj_type=crond_t -F auid>=1000 -F auid!=unset -k cron_exec" >> /etc/audit/rules.d/cron_exec.rules
echo "-a always,exit -F arch=b32 -S execve -F subj_type=crond_t -F auid>=1000 -F auid!=unset -k cron_exec" >> /etc/audit/rules.d/cron_exec.rules
