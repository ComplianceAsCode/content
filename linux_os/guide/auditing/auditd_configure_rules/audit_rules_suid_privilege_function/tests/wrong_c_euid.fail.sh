#!/bin/bash
# packages = audit

OTHER_FILTERS_EUID=" -C uid!=euid -F euid=0"
OTHER_FILTERS_EGID=" -C gid!=euid -F egid=0"

echo '-a always,exit -F arch=b32 -S execve${OTHER_FILTERS_EGID} -k setgid' > /etc/audit/rules.d/privileged.rules
echo '-a always,exit -F arch=b64 -S execve${OTHER_FILTERS_EGID} -k setgid' >> /etc/audit/rules.d/privileged.rules
echo '-a always,exit -F arch=b32 -S execve${OTHER_FILTERS_EGID} -k setuid' >> /etc/audit/rules.d/privileged.rules
echo '-a always,exit -F arch=b64 -S execve${OTHER_FILTERS_EGID} -k setuid' >> /etc/audit/rules.d/privileged.rules
