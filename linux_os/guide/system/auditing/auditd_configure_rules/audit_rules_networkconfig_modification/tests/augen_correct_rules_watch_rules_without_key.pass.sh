#!/bin/bash
# packages = audit

echo "-a always,exit -F arch=b32 -S sethostname,setdomainname -F key=audit_rules_networkconfig_modification" >> /etc/audit/rules.d/networkconfig.rules
echo "-a always,exit -F arch=b64 -S sethostname,setdomainname -F key=audit_rules_networkconfig_modification" >> /etc/audit/rules.d/networkconfig.rules
echo "-w /etc/issue -p wa" >> /etc/audit/rules.d/networkconfig.rules
echo "-w /etc/issue.net -p wa" >> /etc/audit/rules.d/networkconfig.rules
echo "-w /etc/hosts -p wa" >> /etc/audit/rules.d/networkconfig.rules
echo "-w /etc/sysconfig/network -p wa" >> /etc/audit/rules.d/networkconfig.rules
