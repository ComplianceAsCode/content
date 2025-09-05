#!/bin/bash
#
# packages = audit

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S pipe -F auid>={{{ uid_min }}} -F auid!=unset -F key={{{ KEY }}}" >> /etc/audit/rules.d/{{{ KEY }}}.rules
echo "-a always,exit -F arch=b64 -S pipe -F auid>={{{ uid_min }}} -F auid!=unset -F key={{{ KEY }}}" >> /etc/audit/rules.d/{{{ KEY }}}.rules

{{% if CHECK_ROOT_USER %}}
    echo "-a always,exit -F arch=b32 -S pipe -F auid=0 -F auid!=unset -F key={{{ KEY }}}" >> /etc/audit/rules.d/{{{ KEY }}}.rules
    echo "-a always,exit -F arch=b64 -S pipe -F auid=0 -F auid!=unset -F key={{{ KEY }}}" >> /etc/audit/rules.d/{{{ KEY }}}.rules
{{% endif %}}
