#!/bin/bash
# packages = audit
# remediation = bash
# platform = Fedora,Oracle Linux 7,Oracle Linux 8,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8

echo "-a always,exit -F path=/usr/bin/sudo -F auid>=1000 -F auid!=unset -F key=privileged" >> /etc/audit/rules.d/privileged.rules
