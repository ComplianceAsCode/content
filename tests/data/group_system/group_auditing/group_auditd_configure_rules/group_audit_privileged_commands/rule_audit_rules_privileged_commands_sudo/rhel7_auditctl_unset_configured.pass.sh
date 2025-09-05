#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = bash
# platform = Red Hat Enterprise Linux 7

echo "-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=unset -k privileged" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
