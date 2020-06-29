#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash
# platform = Red Hat Enterprise Linux 7

mkdir -p /etc/audit/rules.d
echo "-a always,exit -F path=/usr/bin/newgrp -F auid>=1000 -F auid!=4294967295 -k privileged" >> /etc/audit/rules.d/privileged.rules
