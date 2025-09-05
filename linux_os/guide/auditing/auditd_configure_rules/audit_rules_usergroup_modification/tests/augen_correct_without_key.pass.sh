#!/bin/bash
# packages = audit

echo "-w /etc/group -p wa" > /etc/audit/rules.d/audit_rules_usergroup_modification.rules
echo "-w /etc/passwd -p wa" >> /etc/audit/rules.d/audit_rules_usergroup_modification.rules
echo "-w /etc/gshadow -p wa" >> /etc/audit/rules.d/audit_rules_usergroup_modification.rules
echo "-w /etc/shadow -p wa" >> /etc/audit/rules.d/audit_rules_usergroup_modification.rules
echo "-w /etc/security/opasswd -p wa" >> /etc/audit/rules.d/audit_rules_usergroup_modification.rules
