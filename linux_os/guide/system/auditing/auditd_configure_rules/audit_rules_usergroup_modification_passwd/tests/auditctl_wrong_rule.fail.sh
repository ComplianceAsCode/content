#!/bin/bash

echo "-w /etc/passwd -p w -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
