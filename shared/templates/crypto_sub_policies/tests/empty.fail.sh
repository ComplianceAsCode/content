#!/bin/bash
{{% for sub_policy in SUB_POLICIES %}}
touch /etc/crypto-policies/policies/modules/{{{ sub_policy.module_name }}}.pmod
{{% endfor %}}
