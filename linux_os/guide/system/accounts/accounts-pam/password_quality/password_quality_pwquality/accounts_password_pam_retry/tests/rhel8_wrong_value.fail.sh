#!/bin/bash
# platform = Red Hat Enterprise Linux 8

retry_cnt=7
for auth_file in system-auth password-auth
do
    config_file=/etc/pam.d/${auth_file}

	if grep -q "pam_pwquality\.so.*retry=" "$config_file" ; then
		sed -i --follow-symlinks "/pam_pwquality\.so/ s/\(retry *= *\).*/\1$retry_cnt/" $config_file
	else
		sed -i --follow-symlinks "/pam_pwquality\.so/ s/$/ retry=$retry_cnt/" $config_file
	fi
done
