#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

echo "-w /etc/group -p wa -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/passwd -p wa -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/gshadow -p wa -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/shadow -p wa -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/security/opasswd -p wa -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
