#!/bin/bash
# packages = audit

# This tests situation where key value is not std. And also situation where there is extra spaces in rules.

OTHER_FILTERS=" -C    euid!=uid    -F auid!=unset"

echo "  -a   always,exit   -F   arch=b32   -S   execve   ${OTHER_FILTERS}   -F   key=my_setuid-audit-rule  " > /etc/audit/rules.d/privileged.rules
echo "-a always,exit -F arch=b64 -S execve ${OTHER_FILTERS} -k my_setuid-audit-rule" >> /etc/audit/rules.d/privileged.rules
