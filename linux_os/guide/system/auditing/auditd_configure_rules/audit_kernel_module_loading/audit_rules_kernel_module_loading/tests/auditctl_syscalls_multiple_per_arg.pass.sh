#!/bin/bash
# packages = audit


# Use auditctl, on RHEL7, default is to use augenrules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

rm -f /etc/audit/rules.d/*

# cut out irrelevant rules for this test
sed '1,8d' test_audit.rules > /etc/audit/audit.rules
sed -i '4,7d' /etc/audit/audit.rules
{{% if product in ["ol8"] or 'rhel' in product %}}
sed -i 's/-k modules/-F auid>=1000 -F auid!=unset -k modules/g' /etc/audit/audit.rules
{{% endif %}}
