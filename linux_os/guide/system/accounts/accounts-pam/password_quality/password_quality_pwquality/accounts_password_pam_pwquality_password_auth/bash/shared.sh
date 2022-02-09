# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_rhel

PAM_FILE="password-auth"

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
            authselect apply-changes -b --backup=before-pwquality-hardening.backup
            authselect select $CURRENT_PROFILE
            for feature in $ENABLED_FEATURES; do
                authselect enable-feature $feature;
            done
        fi
        # Include the desired configuration in the custom profile
        CUSTOM_FILE="/etc/authselect/$CURRENT_PROFILE/$PAM_FILE"
        # The line should be included on the top password section
		if [ $(grep -c "^\s*password.*requisite.*pam_pwquality.so" $CUSTOM_FILE) -eq 0 ]; then
  		  sed -i --follow-symlinks '0,/^password.*/s/^password.*/password    requisite                                    pam_pwquality.so\n&/' $CUSTOM_FILE
		fi
        authselect apply-changes -b --backup=after-pwquality-hardening.backup
    else
        echo "
authselect integrity check failed. Remediation aborted!
This remediation could not be applied because the authselect profile is not intact.
It is not recommended to manually edit the PAM files when authselect is available.
In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
        false
    fi
else
    FILE_PATH="/etc/pam.d/$PAM_FILE"
    if [ $(grep -c "^\s*password.*requisite.*pam_pwquality.so" $FILE_PATH) -eq 0 ]; then
        sed -i --follow-symlinks '0,/^password.*/s/^password.*/password    requisite                                    pam_pwquality.so\n&/' $FILE_PATH
    fi
fi
