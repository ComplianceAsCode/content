#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}

{{% if product in ["rhel9", "rhel10"] %}}
echo "-a always,exit -F arch=b32 -F path=/usr/bin/passwd -F perm=x -k test_key" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -F path=/usr/bin/passwd -F perm=x -k test_key" >> /etc/audit/audit.rules
{{% elif product in ["fedora", "ol10"] %}}
echo "-a always,exit -F arch=b32 -F path=/usr/bin/passwd -F perm=x -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -F path=/usr/bin/passwd -F perm=x -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/audit.rules
{{% else %}}
echo "-a always,exit -F path=/usr/bin/passwd -F perm=x -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/audit.rules
{{% endif %}}
