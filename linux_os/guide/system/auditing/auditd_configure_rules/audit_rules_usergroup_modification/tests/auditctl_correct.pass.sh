#!/bin/bash
# packages = audit

# use auditctl
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

echo "-w /etc/group -p wa -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/passwd -p wa -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/gshadow -p wa -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/shadow -p wa -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/security/opasswd -p wa -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
