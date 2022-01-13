# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv

{{{ bash_instantiate_variables("var_password_pam_remember", "var_password_pam_remember_control_flag") }}}

# control required is for rhel8, while requisite is for other distros
CONTROL=${var_password_pam_remember_control_flag}

if [ -f /usr/bin/authselect ]; then
    if authselect check; then
        CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
        # Standard profiles delivered with authselect should not be modified.
        # If not already in use, a custom profile is created preserving the enabled features.
        if [[ ! $CURRENT_PROFILE == custom/* ]]; then
            ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
            authselect create-profile hardening -b $CURRENT_PROFILE
            CURRENT_PROFILE="custom/hardening"
            # Ensure a backup before changing the profile
            authselect apply-changes -b --backup=before-pwhistory-hardening.backup
            authselect select $CURRENT_PROFILE
            for feature in $ENABLED_FEATURES; do
                authselect enable-feature $feature;
            done
        fi
        # Include the desired configuration in the custom profile
        CUSTOM_PASSWORD_AUTH="/etc/authselect/$CURRENT_PROFILE/password-auth"
		if grep -q "^password.*pam_pwhistory.so.*" $CUSTOM_PASSWORD_AUTH; then
			if ! $(grep -q "^[^#].*pam_pwhistory.so.*remember=" $CUSTOM_PASSWORD_AUTH); then
				sed -i --follow-symlinks "/pam_pwhistory.so/ s/$/ remember=$var_password_pam_remember/" $CUSTOM_PASSWORD_AUTH
			else
				sed -r -i --follow-symlinks "s/(.*pam_pwhistory.so.*)(remember=[[:digit:]]+)\s(.*)/\1remember=$var_password_pam_remember \3/g" $CUSTOM_PASSWORD_AUTH
			fi
			# Ensure correct control is being used per os requirement
			if ! grep -q "^password.*$CONTROL.*pam_pwhistory.so.*" $CUSTOM_PASSWORD_AUTH; then
				# Replace incorrect value
				sed -r -i --follow-symlinks "s/(^password.*)(required|requisite)(.*pam_pwhistory\.so.*)$/\1$CONTROL\3/" $CUSTOM_PASSWORD_AUTH
			fi
		else
			sed -i --follow-symlinks "/^password.*requisite.*pam_pwquality.so/a password    $CONTROL     pam_pwhistory.so remember=$var_password_pam_remember use_authtok" $CUSTOM_PASSWORD_AUTH
		fi
        authselect apply-changes -b --backup=after-pwhistory-hardening.backup
    else
        echo "
authselect integrity check failed. Remediation aborted!
This remediation could not be applied because the authselect profile is not intact.
It is not recommended to manually edit the PAM files when authselect is available.
In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
        false
    fi
else
	pamFile="/etc/pam.d/password-auth"
	# is 'password required|requisite pam_pwhistory.so' here?
	if grep -q "^password.*pam_pwhistory.so.*" $pamFile; then
		# is the remember option set?
		option=$(sed -rn 's/^(.*pam_pwhistory\.so.*)(remember=[0-9]+)(.*)$/\2/p' $pamFile)
		if [[ -z $option ]]; then
			# option is not set, append to module
			sed -i --follow-symlinks "/pam_pwhistory.so/ s/$/ remember=$var_password_pam_remember/" $pamFile
		else
			# option is set, replace value
			sed -r -i --follow-symlinks "s/^(.*pam_pwhistory\.so.*)(remember=[0-9]+)(.*)$/\1remember=$var_password_pam_remember\3/" $pamFile
		fi
		# ensure correct control is being used per os requirement
		if ! grep -q "^password.*$CONTROL.*pam_pwhistory.so.*" $pamFile; then
			#replace incorrect value
			sed -r -i --follow-symlinks "s/(^password.*)(required|requisite)(.*pam_pwhistory\.so.*)$/\1$CONTROL\3/" $pamFile
		fi
	else
		# no 'password required|requisite pam_pwhistory.so', add it
		sed -i --follow-symlinks "/^password.*pam_unix.so.*/i password $CONTROL pam_pwhistory.so use_authtok remember=$var_password_pam_remember" $pamFile
	fi
fi
