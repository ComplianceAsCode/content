#!/bin/bash
{{% for module_name, sub_policy in SUB_POLICIES.items() %}}
{{% if module_name != "NO-WEAKMAC" %}}
cat > /etc/crypto-policies/policies/modules/{{{ module_name }}}.pmod << EOF
{{{ sub_policy.key }}} = {{{ sub_policy.value }}}
EOF
{{% endif %}}
{{% endfor %}}
