#!/bin/bash
# packages = pam
# platform = Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora

config_file=/etc/pam.d/password-auth
if [ $(grep -c "^\s*password.*requisite.*pam_pwquality\.so" $config_file) -eq 0 ]; then
    sed -i --follow-symlinks '0,/^password.*/s/^password.*/password		requisite	pam_pwquality.so\n&/' $config_file
fi
