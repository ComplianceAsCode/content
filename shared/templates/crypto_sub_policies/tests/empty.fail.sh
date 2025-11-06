#!/bin/bash
{{% for module_name, sub_policy in SUB_POLICIES.items() %}}
touch /etc/crypto-policies/policies/modules/{{{ module_name }}}.pmod
{{% endfor %}}
