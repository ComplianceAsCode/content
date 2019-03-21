#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = bash
# platform = Red Hat Enterprise Linux 7,Fedora

mkdir -p /etc/audit/rules.d
echo "-a always,exit -F path=/usr/bin/su -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged" >> /etc/audit/rules.d/privileged.rules
