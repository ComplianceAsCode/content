#!/bin/bash
# packages = audit
# remediation = none
# platform = multi_platform_fedora,multi_platform_rhel,Oracle Linux 7,Oracle Linux 8

./generate_privileged_commands_rule.sh {{{ uid_min }}} privileged /tmp/privileged.rules

# Remediation for this rule cannot remove the duplicates
cp /tmp/privileged.rules /etc/audit/rules.d/privileged.rules
sed 's/unset/4294967295/' /tmp/privileged.rules >> /etc/audit/rules.d/privileged.rules
