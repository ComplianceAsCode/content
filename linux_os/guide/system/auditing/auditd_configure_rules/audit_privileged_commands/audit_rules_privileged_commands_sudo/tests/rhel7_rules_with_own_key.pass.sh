#!/bin/bash
# remediation = bash
# platform = Red Hat Enterprise Linux 7,Fedora

echo "-a always,exit -F path=/usr/bin/sudo -F auid>=1000 -F auid!=4294967295 -k own_key" >> /etc/audit/rules.d/privileged.rules
