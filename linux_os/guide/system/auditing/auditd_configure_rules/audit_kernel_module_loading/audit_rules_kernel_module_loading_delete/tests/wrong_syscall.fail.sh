#!/bin/bash
#

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
{{% if product not in ["ol8", "rhel8"] %}}
echo "-a always,exit -F arch=b32 -S delete -F auid>=1000 -F auid!=unset -F key=modules" >> /etc/audit/rules.d/modules.rules
echo "-a always,exit -F arch=b64 -S delete -F auid>=1000 -F auid!=unset -F key=modules" >> /etc/audit/rules.d/modules.rules
{{% else %}}
echo "-a always,exit -F arch=b32 -S delete -F key=modules" >> /etc/audit/rules.d/modules.rules
echo "-a always,exit -F arch=b64 -S delete -F key=modules" >> /etc/audit/rules.d/modules.rules
{{% endif %}}
