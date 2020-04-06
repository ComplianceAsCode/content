#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash
# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8
# This test is here to detect regression of the problem where binaries with names like
# su and sudo caused problems while remediating

echo "-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=unset -k privileged" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
