#!/bin/bash
# packages = audit


mkdir -p /etc/audit/rules.d
echo "-w /etc/passwd -p w -k audit_rules_usergroup_modification" >> /etc/audit/rules.d/login.rules
