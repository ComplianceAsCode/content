#!/bin/bash
# packages = audit


echo "-w {{{ PATH }}} -p wa -k audit_rules_usergroup_modification" >> /etc/audit/rules.d/login.rules
