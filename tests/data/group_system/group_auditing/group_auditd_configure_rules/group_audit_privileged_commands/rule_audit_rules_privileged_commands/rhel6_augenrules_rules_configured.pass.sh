#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash

cp rhel6_audit.rules /etc/audit/rules.d/privileged.rules
cp rhel6_audit.rules /etc/audit/audit.rules
sed -i "s/USE_AUGENRULES=.*/USE_AUGENRULES=\"yes\"/" /etc/sysconfig/auditd
