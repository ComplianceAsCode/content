#!/bin/bash
# packages = audit

rm -f /etc/audit/rules.d/*

# cut out irrelevant rules for this test
sed '8,15d' test_audit.rules > /etc/audit/rules.d/test.rules
{{% if 'ol' in product or 'rhel' in product %}}
sed -i 's/-k modules/-F auid>={{{ uid_min }}} -F auid!=unset -k modules/g' /etc/audit/rules.d/test.rules
{{% endif %}}
