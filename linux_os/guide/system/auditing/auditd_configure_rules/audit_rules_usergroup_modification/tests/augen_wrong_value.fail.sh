#!/bin/bash
# packages = audit

rm -rf /etc/audit/rules.d/*
echo "-w /etc/group -p w -k audit_rules_usergroup_modification" > /etc/audit/rules.d/audit_rules_usergroup_modification.rules
echo "-w /etc/passwd -p w -k audit_rules_usergroup_modification" >> /etc/audit/rules.d/audit_rules_usergroup_modification.rules
echo "-w /etc/gshadow -p w -k audit_rules_usergroup_modification" >> /etc/audit/rules.d/audit_rules_usergroup_modification.rules
echo "-w /etc/shadow -p w -k audit_rules_usergroup_modification" >> /etc/audit/rules.d/audit_rules_usergroup_modification.rules
echo "-w /etc/security/opasswd -p w -k audit_rules_usergroup_modification" >> /etc/audit/rules.d/audit_rules_usergroup_modification.rules
