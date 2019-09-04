#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash
# platform = Red Hat Enterprise Linux 6

sed -i "s/USE_AUGENRULES=.*/USE_AUGENRULES=\"yes\"/" /etc/sysconfig/auditd
