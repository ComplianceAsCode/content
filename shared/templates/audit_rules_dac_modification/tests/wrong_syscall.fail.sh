#!/bin/bash
#
# packages = audit

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S pipe -F auid>={{{ uid_min }}} -F auid!=unset -F key=perm_mod" >> /etc/audit/rules.d/perm_mod.rules
echo "-a always,exit -F arch=b64 -S pipe -F auid>={{{ uid_min }}} -F auid!=unset -F key=perm_mod" >> /etc/audit/rules.d/perm_mod.rules

{{% if CHECK_ROOT_USER %}}
    echo "-a always,exit -F arch=b32 -S pipe -F auid=0 -F auid!=unset -F key=perm_mod" >> /etc/audit/rules.d/perm_mod.rules
    echo "-a always,exit -F arch=b64 -S pipe -F auid=0 -F auid!=unset -F key=perm_mod" >> /etc/audit/rules.d/perm_mod.rules
{{% endif %}}
