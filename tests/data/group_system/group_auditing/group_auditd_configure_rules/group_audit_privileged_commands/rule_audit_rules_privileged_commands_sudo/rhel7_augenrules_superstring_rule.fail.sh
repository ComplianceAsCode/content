#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = bash

echo "-a always,exit -F path=/usr/bin/sudoedit -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged" >> /etc/audit/rules.d/privileged.rules
# This is a trick to fail setup of this test in rhel6 systems
ls /usr/lib/systemd/system/auditd.service
