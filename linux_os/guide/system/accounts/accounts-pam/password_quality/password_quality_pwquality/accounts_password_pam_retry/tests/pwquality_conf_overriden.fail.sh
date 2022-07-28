#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# variables = var_password_pam_retry=3

source common.sh

echo "retry = 3" >  /etc/security/pwquality.conf

for file in ${configuration_files[@]}; do
	{{{ bash_ensure_pam_module_option('/etc/authselect/custom/testingProfile/$file',
                                   'password',
								   'required',
								   'pam_pwquality.so',
								   'retry',
								   '4',
								   '^\s*account') }}}
done

authselect apply-changes
