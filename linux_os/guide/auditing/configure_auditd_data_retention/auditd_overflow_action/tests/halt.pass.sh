#!/bin/bash
# packages = audit
# Ensure test system has proper directories/files for test scenario
bash -x setup.sh

{{%- if product in ["ol7"] %}}
config_file="/etc/audisp/audispd.conf"
{{%- else %}}
config_file="/etc/audit/auditd.conf"
{{%- endif %}}

# remove any occurrence
sed -i "s/^.*overflow_action.*$//" $config_file
echo "overflow_action = halt" >> $config_file
