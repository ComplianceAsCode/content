#!/bin/bash
{{% for module_name, sub_policy in SUB_POLICIES.items() %}}
if [[ -f /etc/crypto-policies/policies/modules/{{{ module_name }}}.pmod ]] ; then
  rm /etc/crypto-policies/policies/modules/{{{ module_name }}}.pmod
fi
{{% endfor %}}
