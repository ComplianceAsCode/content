#!/bin/bash
# packages = audit


echo "-a always,exit -F arch=b32 -S sethostname,setdomainname -F key=audit_rules_networkconfig_modification" >> /etc/audit/rules.d/some.rules
echo "-a always,exit -F arch=b64 -S sethostname,setdomainname -F key=audit_rules_networkconfig_modification" >> /etc/audit/rules.d/some.rules
echo "-w /etc/issue -p wa -k audit_rules_networkconfig_modification" >> /etc/audit/audit.rules
echo "-w /etc/issue.net -p wa -k audit_rules_networkconfig_modification" >> /etc/audit/audit.rules
echo "-w /etc/hosts -p wa -k audit_rules_networkconfig_modification" >> /etc/audit/audit.rules
echo "-w /etc/sysconfig/network -p wa -k audit_rules_networkconfig_modification" >> /etc/audit/audit.rules
