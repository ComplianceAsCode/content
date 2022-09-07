# platform = multi_platform_rhel
# packages = audit

rm -f /etc/audit/rules.d/*

{{%- if product == "rhel7" %}}
echo "-w /usr/bin/cp -p x -F auid!=unset -k module-change" > /etc/audit/rules.d/module-change.rules
{{%- else %}}
echo "-a always,exit -F path=/usr/bin/cp -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged" > /etc/audit/rules.d/privileged.rules
{{%- endif %}}
augenrules
