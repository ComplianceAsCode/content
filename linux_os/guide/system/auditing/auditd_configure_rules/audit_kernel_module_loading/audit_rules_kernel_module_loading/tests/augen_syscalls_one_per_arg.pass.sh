#!/bin/bash
# packages = audit


rm -f /etc/audit/rules.d/*

# cut out irrelevant rules for this test
sed '1,12d' test_audit.rules > /etc/audit/rules.d/test.rules
{{% if product in ["ol8"] or 'rhel' in product %}}
sed -i 's/-k modules/-F auid>=1000 -F auid!=unset -k modules/g' /etc/audit/rules.d/test.rules
{{% endif %}}
