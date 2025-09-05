#!/bin/bash
# packages = audit

{{%- if product in ["rhel7", "ol7"] %}}
config_file="/etc/audisp/audispd.conf"
{{%- else %}}
config_file="/etc/audit/auditd.conf"
{{%- endif %}}

if [[ -f $config_file ]]; then
    rm -f $config_file
fi
