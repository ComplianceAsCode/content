#!/bin/bash
# packages = audit
# Ensure test system has proper directories/files for test scenario
bash -x setup.sh

{{%- if product in ["rhel7", "ol7"] %}}
config_file="/etc/audisp/audispd.conf"
{{%- else %}}
config_file="/etc/audit/auditd.conf"
{{%- endif %}}

# remove any occurrence
sed -i "s/^.*name_format.*$//" $config_file
# put commented out occurrence
echo "# name_format = hostname" >> "$config_file"
