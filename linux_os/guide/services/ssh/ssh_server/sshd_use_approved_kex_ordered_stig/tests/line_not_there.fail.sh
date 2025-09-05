#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu,multi_platform_almalinux
{{% if product in ['ol8', 'rhel8']  -%}}
# remediation = none
{{%- endif %}}

source common.sh
