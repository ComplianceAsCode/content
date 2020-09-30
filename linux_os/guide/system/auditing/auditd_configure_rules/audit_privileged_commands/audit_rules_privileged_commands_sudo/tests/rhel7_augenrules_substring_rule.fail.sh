#!/bin/bash
# remediation = bash
# platform = Red Hat Enterprise Linux 7,Fedora

mkdir -p /etc/audit/rules.d
echo "-a always,exit -F path=/usr/bin/su -F auid>=1000 -F auid!=4294967295 -k privileged" >> /etc/audit/rules.d/privileged.rules
