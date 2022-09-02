#!/bin/bash
# packages = audit
# remediation = bash
# platform = Fedora,Oracle Linux 7,Oracle Linux 8,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8

./generate_privileged_commands_rule.sh 1000 own_key /etc/audit/rules.d/privileged.rules
