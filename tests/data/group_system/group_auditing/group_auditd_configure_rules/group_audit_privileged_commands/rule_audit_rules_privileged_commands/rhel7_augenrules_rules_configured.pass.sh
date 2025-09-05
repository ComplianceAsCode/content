#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash
# platform = Red Hat Enterprise Linux 7,Fedora

mkdir -p /etc/audit/rules.d
./generate_privileged_commands_rule.sh 1000 privileged /etc/audit/rules.d/privileged.rules
