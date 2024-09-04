#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

echo "-w /etc/group -p w -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/passwd -p w -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/gshadow -p w -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/shadow -p w -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/security/opasswd -p w -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
