#!/bin/bash
# packages = audit

OTHER_FILTERS_EUID=" -C uid!=euid -F euid=0"
OTHER_FILTERS_EGID=" -C gid!=egid -F egid=0"

echo "-a never,exit -F arch=b32 -S execve${OTHER_FILTERS_EGID} -k setgid" > /etc/audit/rules.d/privileged.rules
echo "-a never,exit -F arch=b64 -S execve${OTHER_FILTERS_EGID} -k setgid" >> /etc/audit/rules.d/privileged.rules
echo "-a never,exit -F arch=b32 -S execve${OTHER_FILTERS_EUID} -k setuid" >> /etc/audit/rules.d/privileged.rules
echo "-a never,exit -F arch=b64 -S execve${OTHER_FILTERS_EUID} -k setuid" >> /etc/audit/rules.d/privileged.rules
