#!/bin/bash
# packages = audit
{{% if product == "ol8" %}}
# platform = Not Applicable
{{% endif %}}

if [[ $(grep '^ExecStartPost' /usr/lib/systemd/system/auditd.service) ]]; then
    sed -i 's/ExecStartPost=/#ExecStartPost=/g' /usr/lib/systemd/system/auditd.service
fi

echo '-a always,exit -F arch=b32 -S execve -C gid!=egid -F euid=0 -k setgid' > /etc/audit/rules.d/privileged.rules
echo '-a always,exit -F arch=b64 -S execve -C gid!=egid -F euid=0 -k setgid' >> /etc/audit/rules.d/privileged.rules
echo '-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k setuid' >> /etc/audit/rules.d/privileged.rules
echo '-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k setuid' >> /etc/audit/rules.d/privileged.rules
