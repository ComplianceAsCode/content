#!/bin/bash
# packages = audit
# Ensure test system has proper directories/files for test scenario
bash -x setup.sh

{{%- if product in ["rhel7", "ol7"] %}}
config_file="/etc/audisp/audispd.conf"
{{%- else %}}
config_file="/etc/audit/auditd.conf"
{{%- endif %}}

sed -i "s/^.*name_format.*$//" $config_file
