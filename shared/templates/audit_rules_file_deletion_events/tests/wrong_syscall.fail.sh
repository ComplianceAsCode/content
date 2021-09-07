#!/bin/bash
#

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S pipe -F auid>=1000 -F auid!=unset -F key=delete" >> /etc/audit/rules.d/delete.rules
echo "-a always,exit -F arch=b64 -S pipe -F auid>=1000 -F auid!=unset -F key=delete" >> /etc/audit/rules.d/delete.rules
