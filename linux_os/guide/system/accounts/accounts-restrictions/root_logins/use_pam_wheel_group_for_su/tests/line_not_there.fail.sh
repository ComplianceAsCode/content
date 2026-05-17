#!/bin/bash
# variables = var_pam_wheel_group_for_su=sugroup

{{% if product in ["sle16", "slmicro6"] %}}
touch /etc/pam.d/su
{{% endif %}}

#clean possible lines
sed -Ei '/^auth\b.*\brequired\b.*\bpam_wheel\.so/d' /etc/pam.d/su
