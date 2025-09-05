#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_wrlinux
# variables = var_password_pam_remember_control_flag=required
# packages = pam

config_file=/etc/pam.d/password-auth

if grep -q "pam_pwhistory\.so.*remember=" "$config_file" ; then
    sed -i --follow-symlinks "/pam_pwhistory\.so/ s/\(remember *= *\).*//" $config_file
fi
