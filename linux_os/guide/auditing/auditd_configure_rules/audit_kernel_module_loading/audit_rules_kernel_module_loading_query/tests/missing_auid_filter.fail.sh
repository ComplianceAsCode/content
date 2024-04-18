#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# packages = audit

rm -f /etc/audit/rules.d/*

echo "-a always,exit -F arch=b32 -S query_module -k modules" >> /etc/audit/rules.d/modules.rules
echo "-a always,exit -F arch=b64 -S query_module -k modules" >> /etc/audit/rules.d/modules.rules
