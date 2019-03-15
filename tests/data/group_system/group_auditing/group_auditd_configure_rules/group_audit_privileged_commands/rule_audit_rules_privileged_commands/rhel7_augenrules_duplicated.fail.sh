#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp,xccdf_org.ssgproject.content_profile_pci-dss
# Remediation for this rule cannot remove the duplicates
# remediation = none
# platform = Red Hat Enterprise Linux 7,Fedora

mkdir -p /etc/audit/rules.d
./generate_privileged_commands_rule.sh 1000 privileged /tmp/privileged.rules

cp /tmp/privileged.rules /etc/audit/rules.d/privileged.rules
sed 's/unset/4294967295/' /tmp/privileged.rules >> /etc/audit/rules.d/privileged.rules
