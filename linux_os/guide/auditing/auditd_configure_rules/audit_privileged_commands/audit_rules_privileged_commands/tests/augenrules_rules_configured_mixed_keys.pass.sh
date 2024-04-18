#!/bin/bash
# packages = audit
# platform = multi_platform_fedora,multi_platform_rhel,Oracle Linux 7,Oracle Linux 8

./generate_privileged_commands_rule.sh {{{ uid_min }}} privileged /etc/audit/rules.d/privileged.rules
# change key of rules for binaries in /usr/sbin
# A mixed conbination of -k and -F key= should be accepted
sed -i '/sbin/s/-k /-F key=/g' /etc/audit/rules.d/privileged.rules
