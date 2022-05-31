#!/bin/bash
# packages = authselect,pam
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

source common.sh

echo "retry = 3" >  /etc/security/pwquality.conf

for file in ${configuration_files[@]}; do
	{{{ bash_ensure_pam_module_options('/etc/authselect/custom/testingProfile/$file',
                                   'password',
								   'required',
								   'pam_pwquality.so',
								   "retry",
								   "3",
								   "3") }}}
done

authselect apply-changes