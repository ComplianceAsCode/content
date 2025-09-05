#!/bin/bash
{{% if "ubuntu" in product%}}
# packages = auditd
{{% else %}}
# packages = audit
{{% endif %}}

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules\
{{% if product in ["ol7", "ol8"] or 'rhel' in product %}}
echo "-a never,exit -F arch=b32 -S delete_module -F auid>=1000 -F auid!=unset -F key=modules" >> /etc/audit/rules.d/modules.rules
echo "-a never,exit -F arch=b64 -S delete_module -F auid>=1000 -F auid!=unset -F key=modules" >> /etc/audit/rules.d/modules.rules
{{% else %}}
echo "-a never,exit -F arch=b32 -S delete_module -F key=modules" >> /etc/audit/rules.d/modules.rules
echo "-a never,exit -F arch=b64 -S delete_module -F key=modules" >> /etc/audit/rules.d/modules.rules
{{% endif %}}
