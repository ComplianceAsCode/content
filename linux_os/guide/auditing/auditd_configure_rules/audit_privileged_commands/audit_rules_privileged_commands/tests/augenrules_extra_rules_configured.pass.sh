#!/bin/bash
# packages = audit
# platform = multi_platform_fedora,multi_platform_rhel,Oracle Linux 7,Oracle Linux 8

./generate_privileged_commands_rule.sh {{{ uid_min }}} privileged /etc/audit/rules.d/privileged.rules
echo "-a always,exit -F path=/usr/bin/notrelevant -F perm=x -F auid>={{{ uid_min }}} -F auid!=unset -F key=privileged" >> /etc/audit/rules.d/privileged.rules
