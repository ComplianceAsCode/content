#!/bin/bash
# platform = Red Hat Enterprise Linux 8

for auth_file in system-auth password-auth
do
    config_file=/etc/pam.d/${auth_file}

    if grep -q "pam_pwquality\.so.*retry=" "$config_file" ; then
        sed -i --follow-symlinks "/pam_pwquality\.so/ s/\(retry *= *\).*//" $config_file
    fi
done
