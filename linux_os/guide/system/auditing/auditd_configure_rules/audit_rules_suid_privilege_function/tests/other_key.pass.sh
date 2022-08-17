#!/bin/bash
# packages = audit

# This tests situation where key value is not std. And also situation where there is extra spaces in rules.

echo '  -a   always,exit   -F   arch=b32   -S   execve   -C   gid!=egid   -F   egid=0   -F   key=my_setgid-audit-rule  ' > /etc/audit/rules.d/privileged.rules
echo '  -a   always,exit   -F   arch=b64   -S   execve   -C   gid!=egid   -F   egid=0   -k   my_setgid-audit-rule  ' >> /etc/audit/rules.d/privileged.rules
echo '-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k my_setuid-audit-rule' >> /etc/audit/rules.d/privileged.rules
echo '-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -F key=my_setuid-audit-rule' >> /etc/audit/rules.d/privileged.rules
