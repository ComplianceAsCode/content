#!/bin/bash
# packages = audit
# remediation = bash
# platform = Fedora,Oracle Linux 7,Red Hat Enterprise Linux 7

echo "-a always,exit -F path=/usr/bin/sudoedit -F auid>=1000 -F auid!=4294967295 -k privileged" >> /etc/audit/rules.d/privileged.rules
