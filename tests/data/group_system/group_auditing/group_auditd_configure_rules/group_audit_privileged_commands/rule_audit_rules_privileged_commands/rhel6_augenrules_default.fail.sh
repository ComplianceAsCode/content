#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash

sed -i "s/USE_AUGENRULES=.*/USE_AUGENRULES=\"yes\"/" /etc/sysconfig/auditd
