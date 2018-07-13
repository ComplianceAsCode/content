#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash

cp rhel7_own_key.rules /etc/audit/rules.d/privileged.rules
cp rhel7_own_key.rules /etc/audit/audit.rules
