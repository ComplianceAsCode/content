#!/bin/bash
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_sle

{{% if product in [ "sle12", "sle15" ] %}}
for auth_file in common-password password-auth; do
{{% else %}}
for auth_file in system-auth password-auth; do
{{% endif %}}
    config_file=/etc/pam.d/${auth_file}
    if grep -q "pam_pwhistory\.so.*remember=" "$config_file" ; then
        sed -i --follow-symlinks "/pam_pwhistory\.so/ s/\(remember *= *\).*//" $config_file
    fi
done
