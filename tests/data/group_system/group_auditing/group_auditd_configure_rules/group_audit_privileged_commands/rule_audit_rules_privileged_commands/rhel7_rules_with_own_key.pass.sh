#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash

cp rhel7_own_key.rules /etc/audit/rules.d/privileged.rules
cp rhel7_own_key.rules /etc/audit/audit.rules
# This is a trick to fail setup of this test in rhel6 systems
ls /usr/lib/systemd/system/auditd.service
