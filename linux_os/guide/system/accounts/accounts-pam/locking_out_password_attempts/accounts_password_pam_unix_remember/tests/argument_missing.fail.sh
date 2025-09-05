#!/bin/bash
# platform = multi_platform_rhel,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_wrlinux

for auth_file in system-auth password-auth
do
    config_file=/etc/pam.d/${auth_file}

    if grep -q "pam_pwhistory\.so.*remember=" "$config_file" ; then
        sed -i --follow-symlinks "/pam_pwhistory\.so/ s/\(remember *= *\).*//" $config_file
    fi
done
