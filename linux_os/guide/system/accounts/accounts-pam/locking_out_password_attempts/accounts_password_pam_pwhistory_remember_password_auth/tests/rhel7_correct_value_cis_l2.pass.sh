#!/bin/bash
# packages = pam
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7
# profiles = xccdf_org.ssgproject.content_profile_cis

remember_cnt=24
control_flag='requisite'

config_file=/etc/pam.d/password-auth

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
	if ! grep -q "^password.*$control_flag.*pam_pwhistory\.so.*" $config_file; then
		#replace incorrect value
		sed -r -i --follow-symlinks "s/(^password.*)(required|requisite)(.*pam_pwhistory\.so.*)$/\1$control_flag\3/" $config_file
	fi
else
	# no 'password required|requisite pam_pwhistory.so', add it
	sed -i --follow-symlinks "/^password.*pam_unix\.so.*/i password $control_flag pam_pwhistory.so use_authtok remember=$remember_cnt" $config_file
fi

