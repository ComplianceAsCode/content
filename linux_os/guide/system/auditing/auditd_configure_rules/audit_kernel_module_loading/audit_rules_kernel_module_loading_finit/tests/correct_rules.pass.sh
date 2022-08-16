#!/bin/bash
{{% if "ubuntu" in product%}}
# packages = auditd
{{% else %}}
# packages = audit
{{% endif %}}

{{% if product in ["ol7", "ol8"] or 'rhel' in product %}}
echo "-a always,exit -F arch=b32 -S finit_module -F auid>=1000 -F auid!=unset -k modules" >> /etc/audit/rules.d/modules.rules
echo "-a always,exit -F arch=b64 -S finit_module -F auid>=1000 -F auid!=unset -k modules" >> /etc/audit/rules.d/modules.rules
{{% else %}}
echo "-a always,exit -F arch=b32 -S finit_module -k modules" >> /etc/audit/rules.d/modules.rules
echo "-a always,exit -F arch=b64 -S finit_module -k modules" >> /etc/audit/rules.d/modules.rules
{{% endif %}}
