#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash
# platform = Red Hat Enterprise Linux 6

./generate_privileged_commands_rule.sh 500 privileged /etc/audit/audit.rules
