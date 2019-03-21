#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash
# platform = Red Hat Enterprise Linux 7,Fedora

mkdir -p /etc/audit/rules.d
./generate_privileged_commands_rule.sh 1000 privileged /etc/audit/rules.d/privileged.rules
# change key of rules for binaries in /usr/sbin
# A mixed conbination of -k and -F key= should be accepted
sed -i '/sbin/s/-k /-F key=/g' /etc/audit/rules.d/privileged.rules
