#!/bin/bash
# packages = audit
# remediation = bash
# platform = Fedora,Oracle Linux 7,Oracle Linux 8,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8

./generate_privileged_commands_rule.sh 1000 privileged /etc/audit/rules.d/privileged.rules
# change key of rules for binaries in /usr/sbin
# A mixed conbination of -k and -F key= should be accepted
sed -i '/sbin/s/-k /-F key=/g' /etc/audit/rules.d/privileged.rules
