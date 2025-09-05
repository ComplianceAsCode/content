#!/bin/bash


echo "-a always,exit -F arch=b32 -S fchown -F auid>=1000 -F auid!=unset -F key=perm_mod" >> /etc/audit/rules.d/perm_mod.rules
echo "-a always,exit -F arch=b64 -S fchown -F auid>=1000 -F auid!=unset -F key=perm_mod" >> /etc/audit/rules.d/perm_mod.rules

