#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}

rm -rf /etc/audit/rules.d/*
rm /etc/audit/audit.rules

echo "-w {{{ PATH }}} -p wa -k {{{ rule_id }}}" >> /etc/audit/audit.rules
