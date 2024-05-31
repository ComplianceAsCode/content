#!/bin/bash
# packages = audit

{{% if product == "ol8" %}}
OTHER_FILTERS_EUID=" -C uid!=egid"
OTHER_FILTERS_EGID=" -C gid!=egid"
{{% else %}}
OTHER_FILTERS_EUID=" -C uid!=egid -F euid=0"
OTHER_FILTERS_EGID=" -C gid!=egid -F egid=0"
{{% endif %}}

echo '-a always,exit -F arch=b32 -S execve${OTHER_FILTERS_EGID} -k setgid' > /etc/audit/rules.d/privileged.rules
echo '-a always,exit -F arch=b64 -S execve${OTHER_FILTERS_EGID} -k setgid' >> /etc/audit/rules.d/privileged.rules
echo '-a always,exit -F arch=b32 -S execve${OTHER_FILTERS_EGID} -k setuid' >> /etc/audit/rules.d/privileged.rules
echo '-a always,exit -F arch=b64 -S execve${OTHER_FILTERS_EGID} -k setuid' >> /etc/audit/rules.d/privileged.rules
