#!/bin/bash
# packages = audit

echo "-w {{{ PATH }}} -p wa -k audit_rules_networkconfig_modification" >> /etc/audit/rules.d/networkconfig.rules
