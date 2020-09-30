#!/bin/bash
# remediation = bash
# platform = Fedora,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8

mkdir -p /etc/audit/rules.d
./generate_privileged_commands_rule.sh 1000 privileged /etc/audit/rules.d/privileged.rules
# change key of rules for binaries in /usr/sbin
# A mixed conbination of -k and -F key= should be accepted
sed -i '/sbin/s/-k /-F key=/g' /etc/audit/rules.d/privileged.rules
