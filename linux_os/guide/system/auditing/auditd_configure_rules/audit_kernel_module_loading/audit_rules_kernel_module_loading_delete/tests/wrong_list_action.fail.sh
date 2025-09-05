#!/bin/bash
# packages = audit

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules\
{{% if "ol" in product or 'rhel' in product or 'ubuntu' in product %}}
echo "-a never,exit -F arch=b32 -S delete_module -F auid>={{{ uid_min }}} -F auid!=unset -F key=modules" >> /etc/audit/rules.d/modules.rules
echo "-a never,exit -F arch=b64 -S delete_module -F auid>={{{ uid_min }}} -F auid!=unset -F key=modules" >> /etc/audit/rules.d/modules.rules
{{% else %}}
echo "-a never,exit -F arch=b32 -S delete_module -F key=modules" >> /etc/audit/rules.d/modules.rules
echo "-a never,exit -F arch=b64 -S delete_module -F key=modules" >> /etc/audit/rules.d/modules.rules
{{% endif %}}
