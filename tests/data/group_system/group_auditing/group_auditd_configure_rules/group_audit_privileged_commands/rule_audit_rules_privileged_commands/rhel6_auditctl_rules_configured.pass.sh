#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash

cp rhel6_audit.rules /etc/audit/rules.d/privileged.rules
cp rhel6_audit.rules /etc/audit/audit.rules
# This is a trick to fail setup of this test in rhel7 systems
ls /etc/sysconfig/auditd
