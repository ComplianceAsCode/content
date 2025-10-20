#!/bin/bash
{{% for sub_policy in SUB_POLICIES %}}
cat > /etc/crypto-policies/policies/modules/{{{ sub_policy.module_name }}}.pmod << EOF
{{{ sub_policy.key }}} = ABCDEFGHIJKLMNOPQRSTUVWXYZ
EOF
{{% endfor %}}
