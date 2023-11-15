#!/bin/bash
# packages = audit

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
{{% if "ol" in product or 'rhel' in product or 'ubuntu' in product %}}
echo "-a always,exit -F arch=b32 -S delete -F auid>={{{ uid_min }}} -F auid!=unset -F key=modules" >> /etc/audit/rules.d/modules.rules
echo "-a always,exit -F arch=b64 -S delete -F auid>={{{ uid_min }}} -F auid!=unset -F key=modules" >> /etc/audit/rules.d/modules.rules
{{% else %}}
echo "-a always,exit -F arch=b32 -S delete -F key=modules" >> /etc/audit/rules.d/modules.rules
echo "-a always,exit -F arch=b64 -S delete -F key=modules" >> /etc/audit/rules.d/modules.rules
{{% endif %}}
