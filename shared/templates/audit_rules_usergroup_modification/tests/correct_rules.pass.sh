#!/bin/bash
#

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
echo "-w {{{ PATH }}} -p wa -k audit_rules_usergroup_modification" >> /etc/audit/rules.d/audit_rules_usergroup_modification.rules
