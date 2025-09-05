#!/bin/bash
# packages = audit


echo "-a always,exit -F arch=b32 -S openat -F a2&03 -F path=/etc/password -F auid>=1000 -F auid!=unset -F key=user-modify" >> /etc/audit/rules.d/var_log_audit.rules
echo "-a always,exit -F arch=b64 -S openat -F a2&03 -F path=/etc/passwd -F auid>=1000 -F auid!=unset -F key=user-modify" >> /etc/audit/rules.d/var_log_audit.rules
