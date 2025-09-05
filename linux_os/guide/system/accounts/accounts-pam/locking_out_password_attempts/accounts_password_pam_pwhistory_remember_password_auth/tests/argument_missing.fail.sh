#!/bin/bash
# platform = Oracle Linux 7, Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora
# packages = pam

config_file=/etc/pam.d/password-auth

if grep -q "pam_pwhistory\.so.*remember=" "$config_file" ; then
    sed -i --follow-symlinks "/pam_pwhistory\.so/ s/\(remember *= *\).*//" $config_file
fi
