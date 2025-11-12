#!/bin/bash
# packages = crypto-policies-scripts
{{% for sub_policy in SUB_POLICIES %}}
cat > /etc/crypto-policies/policies/modules/{{{ sub_policy.module_name }}}.pmod << EOF
{{{ sub_policy.key }}} = {{{ sub_policy.value }}}
EOF
{{% endfor %}}
