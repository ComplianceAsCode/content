#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash

./generate_privileged_commands_rule.sh 500 privileged /etc/audit/audit.rules
# This is a trick to fail setup of this test in rhel7 systems
ls /etc/sysconfig/auditd
