#!/bin/bash
# platform = Red Hat Enterprise Linux 8

remember_cnt=3
for auth_file in system-auth password-auth
do
    config_file=/etc/pam.d/${auth_file}

	# is 'password sufficient pam_unix.so' here?
	if grep -q "^password.*pam_unix.so.*" $config_file; then
		# is the remember option set?
		option=$(sed -rn 's/^(.*pam_unix\.so.*)(remember=[0-9]+)(.*)$/\2/p' $config_file)
		if [[ -z $option ]]; then
			# option is not set, append to module
			sed -i --follow-symlinks "/pam_unix.so/ s/$/ remember=$remember_cnt/" $config_file
		else
			# option is set, replace value
			sed -r -i --follow-symlinks "s/^(.*pam_unix\.so.*)(remember=[0-9]+)(.*)$/\1remember=$remember_cnt\3/" $config_file
		fi
		# ensure corect control is being used per os requirement
		if ! grep -q "^password.*sufficient*pam_unix.so.*" $config_file; then
			#replace incorrect value
			sed -r -i --follow-symlinks "s/(^password.*)(sufficient)(.*pam_unix\.so.*)$/\1sufficient\3/" $config_file
		fi
	else
		# no 'password sufficient pam_unix.so', add it
		sed -i --follow-symlinks "/^password.*pam_unix.so.*/i password sufficient pam_unix.so use_authtok remember=$remember_cnt" $config_file
	fi
done
