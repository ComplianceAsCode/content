#!/bin/bash
# packages = audit
{{% if product in ["ol8", "ubuntu2404"] %}}
# platform = Not Applicable
{{% endif %}}

echo '-a always,exit -F arch=b32 -S execve -C gid!=egid -F euid=0 -k setgid' > /etc/audit/rules.d/privileged.rules
echo '-a always,exit -F arch=b64 -S execve -C gid!=egid -F euid=0 -k setgid' >> /etc/audit/rules.d/privileged.rules
echo '-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k setuid' >> /etc/audit/rules.d/privileged.rules
echo '-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k setuid' >> /etc/audit/rules.d/privileged.rules
