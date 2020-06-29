#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

echo "-a always,exit -F dir=/var/log/audit/ -F perm=r -F auid>=1000 -F auid!=4294967295 -F key=access-audit-trail" >> /etc/audit/rules.d/var_log_audit.rules
