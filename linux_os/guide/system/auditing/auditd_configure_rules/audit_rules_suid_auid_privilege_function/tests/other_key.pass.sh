#!/bin/bash
# packages = audit

# This tests situation where key value is not std. And also situation where there is extra spaces in rules.

OTHER_FILTERS=" -C    euid!=uid    -F auid!=unset"

echo "  -a   always,exit   -F   arch=b32   ${OTHER_FILTERS}   -S   execve   -F   key=my_setuid-audit-rule  " > /etc/audit/rules.d/privileged.rules
echo "-a always,exit -F arch=b64 ${OTHER_FILTERS} -S execve -k my_setuid-audit-rule" >> /etc/audit/rules.d/privileged.rules
