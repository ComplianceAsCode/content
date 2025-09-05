# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv

{{{ bash_instantiate_variables("var_password_pam_unix_rounds") }}}

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
            authselect apply-changes -b --backup=before-rounds-hardening.backup
            authselect select $CURRENT_PROFILE
            for feature in $ENABLED_FEATURES; do
                authselect enable-feature $feature;
            done
        fi
        # Include the desired configuration in the custom profile
        CUSTOM_PASSWORD_AUTH="/etc/authselect/$CURRENT_PROFILE/password-auth"
		if ! grep -q "^\s*password.*pam_unix.so.*rounds=" $CUSTOM_PASSWORD_AUTH; then
			sed -i --follow-symlinks "/^\s*password.*pam_unix.so/ s/$/ rounds=$var_password_pam_unix_rounds/" $CUSTOM_PASSWORD_AUTH
		else
			sed -r -i --follow-symlinks "s/(^\s*password.*pam_unix.so.*)(rounds=[[:digit:]]+)(.*)/\1rounds=$var_password_pam_unix_rounds \3/g" $CUSTOM_PASSWORD_AUTH
		fi
        authselect apply-changes -b --backup=after-rounds-hardening.backup
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

    if grep -q "rounds=" $pamFile; then
        sed -iP --follow-symlinks "/password[[:space:]]\+sufficient[[:space:]]\+pam_unix\.so/ \
                                        s/rounds=[[:digit:]]\+/rounds=$var_password_pam_unix_rounds/" $pamFile
    else
        sed -iP --follow-symlinks "/password[[:space:]]\+sufficient[[:space:]]\+pam_unix\.so/ s/$/ rounds=$var_password_pam_unix_rounds/" $pamFile
    fi
fi
