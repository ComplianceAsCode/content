#!/bin/bash
# packages = audit
# variables = var_auditd_name_format=hostname|fqd|numeric
# Ensure test system has proper directories/files for test scenario
bash -x setup.sh

{{%- if product in ["ol7"] %}}
config_file="/etc/audisp/audispd.conf"
{{%- else %}}
config_file="/etc/audit/auditd.conf"
{{%- endif %}}

sed -i "s/^.*name_format.*$//" $config_file
