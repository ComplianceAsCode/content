#!/bin/bash
# Use this script to ensure the audit directory structure and audit conf file
# exist in the test env.
config_file=/etc/audit/auditd.conf

# Ensure directory structure exists (useful for container based testing)
test -d /etc/audit/ || mkdir -p /etc/audit/

test -f $config_file || touch $config_file
