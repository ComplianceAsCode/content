#!/bin/bash
# remediation = bash
# platform = Fedora,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8

./generate_privileged_commands_rule.sh 1000 own_key /etc/audit/rules.d/privileged.rules
