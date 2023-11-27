#!/bin/bash
# packages = audit

{{% if product != "ol8" %}}
OTHER_FILTERS_EUID=" -F euid=0"
OTHER_FILTERS_EGID=" -F egid=0"
{{% endif %}}

echo "-a always,exit -F arch=b32 -S execve -C gid!=guid${OTHER_FILTERS_EGID} -k setgid" > /etc/audit/rules.d/privileged.rules
echo "-a always,exit -F arch=b64 -S execve${OTHER_FILTERS_EGID} -k setgid" >> /etc/audit/rules.d/privileged.rules
echo "-a always,exit -F arch=b32 -S execve${OTHER_FILTERS_EUID} -k setuid" >> /etc/audit/rules.d/privileged.rules
echo "-a always,exit -F arch=b64 -S execve -C uid!=euid${OTHER_FILTERS_EUID} -k setuid" >> /etc/audit/rules.d/privileged.rules
