#!/bin/bash
{{% for module_name, sub_policy in SUB_POLICIES.items() %}}
cat > /etc/crypto-policies/policies/modules/{{{ module_name }}}.pmod << EOF
{{{ sub_policy.key }}} = ABCDEFGHIJKLMNOPQRSTUVWXYZ
EOF
{{% endfor %}}
