#!/bin/bash


rm -rf /etc/audit/rules.d/*.rules
mkdir -p /etc/audit/rules.d/
echo "-a always,exit -F arch=b32 -S adjtimex -k audit_time_rules" >> /etc/audit/rules.d/time.rules
echo "-a always,exit -F arch=b64 -S adjtimex -k audit_time_rules" >> /etc/audit/rules.d/time.rules
