#!/bin/bash
# packages = audit
# Remediation for this rule cannot remove the duplicates
# remediation = none
# platform = Fedora,Oracle Linux 7,Oracle Linux 8,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8

./generate_privileged_commands_rule.sh 1000 privileged /tmp/privileged.rules

cp /tmp/privileged.rules /etc/audit/rules.d/privileged.rules
sed 's/unset/4294967295/' /tmp/privileged.rules >> /etc/audit/rules.d/privileged.rules
