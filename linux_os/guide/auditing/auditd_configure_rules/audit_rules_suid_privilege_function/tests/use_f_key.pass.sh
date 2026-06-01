#!/bin/bash
# packages = audit

OTHER_FILTERS_EUID=" -C uid!=euid -F euid=0"
OTHER_FILTERS_EGID=" -C gid!=egid -F egid=0"

echo "-a always,exit -F arch=b32 -S execve${OTHER_FILTERS_EGID} -F key=setgid" > /etc/audit/rules.d/privileged.rules
echo "-a always,exit -F arch=b64 -S execve${OTHER_FILTERS_EGID} -F key=setgid" >> /etc/audit/rules.d/privileged.rules
echo "-a always,exit -F arch=b32 -S execve${OTHER_FILTERS_EUID} -F key=setuid" >> /etc/audit/rules.d/privileged.rules
echo "-a always,exit -F arch=b64 -S execve${OTHER_FILTERS_EUID} -F key=setuid" >> /etc/audit/rules.d/privileged.rules
