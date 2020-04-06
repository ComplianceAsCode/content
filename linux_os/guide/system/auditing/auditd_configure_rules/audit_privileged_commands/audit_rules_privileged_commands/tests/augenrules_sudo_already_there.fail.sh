#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash
# platform = Fedora,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8

# This test is here to detect regression of the problem where binaries with names like
# su and sudo caused problems while remediating

mkdir -p /etc/audit/rules.d
echo "-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged" >> /etc/audit/rules.d/privileged.rules
