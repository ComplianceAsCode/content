#!/bin/bash
# packages = crypto-policies-scripts
{{% for sub_policy in SUB_POLICIES %}}
if [[ -f /etc/crypto-policies/policies/modules/{{{ sub_policy.module_name }}}.pmod ]] ; then
  rm /etc/crypto-policies/policies/modules/{{{ sub_policy.module_name }}}.pmod
fi
{{% endfor %}}
