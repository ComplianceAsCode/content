#!/bin/bash
# platform = Oracle Linux 7,Red Hat Virtualization 4,multi_platform_fedora,SUSE Linux Enterprise 12

{{% if "sle12" in product %}}
for auth_file in common-password password-auth; do
{{% else %}}
for auth_file in system-auth password-auth; do
{{% endif %}}
    config_file=/etc/pam.d/${auth_file}
    if grep -q "pam_pwhistory\.so.*remember=" "$config_file" ; then
        sed -i --follow-symlinks "/pam_pwhistory\.so/ s/\(remember *= *\).*//" $config_file
    fi
done
