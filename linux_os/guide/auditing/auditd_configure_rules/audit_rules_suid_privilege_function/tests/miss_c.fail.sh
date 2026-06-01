#!/bin/bash
# packages = audit

echo "-a always,exit -F arch=b32 -S execve -C gid!=guid${OTHER_FILTERS_EGID} -k setgid" > /etc/audit/rules.d/privileged.rules
echo "-a always,exit -F arch=b64 -S execve${OTHER_FILTERS_EGID} -k setgid" >> /etc/audit/rules.d/privileged.rules
echo "-a always,exit -F arch=b32 -S execve${OTHER_FILTERS_EUID} -k setuid" >> /etc/audit/rules.d/privileged.rules
echo "-a always,exit -F arch=b64 -S execve -C uid!=euid${OTHER_FILTERS_EUID} -k setuid" >> /etc/audit/rules.d/privileged.rules
