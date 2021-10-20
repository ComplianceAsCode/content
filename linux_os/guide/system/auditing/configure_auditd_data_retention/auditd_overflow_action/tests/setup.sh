#!/bin/bash
# Use this script to ensure the audit directory structure and audit conf file
# exist in the test env.
{{%- if product in ["rhel7", "ol7"] %}}
config_file="/etc/audisp/audispd.conf"
# Ensure directory structure exists (useful for container based testing)
test -d /etc/audisp/ || mkdir -p /etc/audisp/
{{%- else %}}
config_file="/etc/audit/auditd.conf"
# Ensure directory structure exists (useful for container based testing)
test -d /etc/audit/ || mkdir -p /etc/audit/
{{%- endif %}}

test -f $config_file || touch $config_file
