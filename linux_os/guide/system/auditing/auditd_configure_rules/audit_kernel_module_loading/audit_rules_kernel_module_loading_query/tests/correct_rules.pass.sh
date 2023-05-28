#!/bin/bash
# packages = audit

echo "-a always,exit -F arch=b32 -S query_module -F auid>={{{ uid_min }}} -F auid!=unset -k modules" >> /etc/audit/rules.d/modules.rules
echo "-a always,exit -F arch=b64 -S query_module -F auid>={{{ uid_min }}} -F auid!=unset -k modules" >> /etc/audit/rules.d/modules.rules
