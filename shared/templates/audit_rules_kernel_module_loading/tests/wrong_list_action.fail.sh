#!/bin/bash
# packages = audit

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules\
{{% if "ol" in families or 'rhel' in product or 'ubuntu' in product %}}
echo "-a never,exit -F arch=b32 -S {{{ NAME }}} -F auid>={{{ uid_min }}} -F auid!=unset -F key=modules" >> /etc/audit/rules.d/modules.rules
echo "-a never,exit -F arch=b64 -S {{{ NAME }}} -F auid>={{{ uid_min }}} -F auid!=unset -F key=modules" >> /etc/audit/rules.d/modules.rules
{{% else %}}
echo "-a never,exit -F arch=b32 -S {{{ NAME }}} -F key=modules" >> /etc/audit/rules.d/modules.rules
echo "-a never,exit -F arch=b64 -S {{{ NAME }}} -F key=modules" >> /etc/audit/rules.d/modules.rules
{{% endif %}}
