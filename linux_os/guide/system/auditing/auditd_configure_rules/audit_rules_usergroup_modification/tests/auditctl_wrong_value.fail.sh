#!/bin/bash
# packages = audit

# use auditctl
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

echo "-w /etc/group -p w -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/passwd -p w -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/gshadow -p w -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/shadow -p w -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
echo "-w /etc/security/opasswd -p w -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
