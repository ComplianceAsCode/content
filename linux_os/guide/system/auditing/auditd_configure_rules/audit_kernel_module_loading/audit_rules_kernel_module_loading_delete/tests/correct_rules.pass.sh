#!/bin/bash
#

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S delete_module -F key=modules" >> /etc/audit/rules.d/modules.rules
echo "-a always,exit -F arch=b64 -S delete_module -F key=modules" >> /etc/audit/rules.d/modules.rules
