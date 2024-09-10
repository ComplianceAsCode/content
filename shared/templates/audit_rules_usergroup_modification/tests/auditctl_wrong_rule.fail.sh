#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}

echo "-w {{{ PATH }}} -p w -k audit_rules_usergroup_modification" >> /etc/audit/audit.rules
