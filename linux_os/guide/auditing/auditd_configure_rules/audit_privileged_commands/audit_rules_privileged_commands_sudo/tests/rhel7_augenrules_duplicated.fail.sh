#!/bin/bash
# packages = audit
# remediation = bash
# platform = Fedora

echo "-a always,exit -F path=/usr/bin/sudo -F auid>={{{ uid_min }}} -F auid!=4294967295 -k privileged" >> /etc/audit/rules.d/privileged.rules
echo "-a always,exit -F path=/usr/bin/sudo -F auid>={{{ uid_min }}} -F auid!=unset -F key=privileged" >> /etc/audit/rules.d/privileged.rules
