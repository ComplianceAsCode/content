# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("var_password_pam_unix_remember") }}}

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"
# control required is for rhel8, while requisite is for other distros
{{% if product == "rhel8" -%}}
CONTROL='required'
{{%- else -%}}
CONTROL='requisite'
{{%- endif %}}

for pamFile in "${AUTH_FILES[@]}"
do
	# if PAM file is missing, system is not using PAM or broken
	if [ ! -f $pamFile ]; then
		continue
	fi

	# is 'password required|requisite pam_pwhistory.so' here?
	if grep -q "^password.*pam_pwhistory.so.*" $pamFile; then
		# is the remember option set?
		option=$(sed -rn 's/^(.*pam_pwhistory\.so.*)(remember=[0-9]+)(.*)$/\2/p' $pamFile)
		if [[ -z $option ]]; then
			# option is not set, append to module
			sed -i --follow-symlinks "/pam_pwhistory.so/ s/$/ remember=$var_password_pam_unix_remember/"
		else
			# option is set, replace value
			sed -r -i --follow-symlinks "s/^(.*pam_pwhistory\.so.*)(remember=[0-9]+)(.*)$/\1remember=$var_password_pam_unix_remember\3/" $pamFile
		fi
		# ensure corect control is being used per os requirement
		if ! grep -q "^password.*$CONTROL.*pam_pwhistory.so.*" $pamFile; then
			#replace incorrect value
			sed -r -i --follow-symlinks "s/(^password.*)(required|requisite)(.*pam_pwhistory\.so.*)$/\1$CONTROL\3/" $pamFile
		fi
	else
		# no 'password required|requisite pam_pwhistory.so', add it
		sed -i --follow-symlinks "/^password.*pam_unix.so.*/i password $CONTROL pam_pwhistory.so use_authtok remember=$var_password_pam_unix_remember" $pamFile
	fi
done
