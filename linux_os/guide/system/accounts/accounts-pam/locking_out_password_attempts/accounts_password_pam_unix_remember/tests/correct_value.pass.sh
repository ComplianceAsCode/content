#!/bin/bash
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora
# variables = var_password_pam_unix_remember=5

remember_cnt=5
for auth_file in system-auth password-auth
do
    config_file=/etc/pam.d/${auth_file}

	# is 'password required|requisite pam_pwhistory.so' here?
	if grep -q "^password.*pam_pwhistory\.so.*" $config_file; then
		# is the remember option set?
		option=$(sed -rn 's/^(.*pam_pwhistory\.so.*)(remember=[0-9]+)(.*)$/\2/p' $config_file)
		if [[ -z $option ]]; then
			# option is not set, append to module
			sed -i --follow-symlinks "/pam_pwhistory.so/ s/$/ remember=$remember_cnt/"
		else
			# option is set, replace value
			sed -r -i --follow-symlinks "s/^(.*pam_pwhistory\.so.*)(remember=[0-9]+)(.*)$/\1remember=$remember_cnt\3/" $config_file
		fi
		# ensure corect control is being used per os requirement
		if ! grep -q "^password.*requisite.*pam_pwhistory\.so.*" $config_file; then
			#replace incorrect value
			sed -r -i --follow-symlinks "s/(^password.*)(required|requisite)(.*pam_pwhistory\.so.*)$/\1requisite\3/" $config_file
		fi
	else
		# no 'password required|requisite pam_pwhistory.so', add it
		sed -i --follow-symlinks "/^password.*pam_unix\.so.*/i password requisite pam_pwhistory.so use_authtok remember=$remember_cnt" $config_file
	fi
done
