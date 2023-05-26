#!/bin/bash
# packages = audit

# This tests situation where key value is not std. And also situation where there is extra spaces in rules.

{{% if product == "ol8" %}}
OTHER_FILTERS_EUID=" -C     uid!=euid"
OTHER_FILTERS_EGID=" -C     gid!=egid"
{{% else %}}
OTHER_FILTERS_EUID=" -C    uid!=euid    -F euid=0"
OTHER_FILTERS_EGID=" -C    gid!=egid    -F egid=0"
{{% endif %}}

echo "  -a   always,exit   -F   arch=b32   -S   execve   ${OTHER_FILTERS_EGID}   -F   key=my_setgid-audit-rule  " > /etc/audit/rules.d/privileged.rules
echo "  -a   always,exit   -F   arch=b64   -S   execve   ${OTHER_FILTERS_EGID}   -k   my_setgid-audit-rule  " >> /etc/audit/rules.d/privileged.rules
echo "-a always,exit -F arch=b32 -S execve ${OTHER_FILTERS_EUID} -k my_setuid-audit-rule" >> /etc/audit/rules.d/privileged.rules
echo "-a always,exit -F arch=b64 -S execve ${OTHER_FILTERS_EUID} -F key=my_setuid-audit-rule" >> /etc/audit/rules.d/privileged.rules
