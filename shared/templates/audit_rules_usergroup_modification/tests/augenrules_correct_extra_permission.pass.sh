#!/bin/bash
# packages = audit


echo "-w {{{ PATH }}} -p wra -k audit_rules_usergroup_modification" >> /etc/audit/rules.d/login.rules
