#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Oracle Linux 8

rm -f /etc/audit/rules.d/*

echo "-a always,exit -F arch=b32 -S finit_module -k modules" >> /etc/audit/rules.d/modules.rules
echo "-a always,exit -F arch=b64 -S finit_module -k modules" >> /etc/audit/rules.d/modules.rules
