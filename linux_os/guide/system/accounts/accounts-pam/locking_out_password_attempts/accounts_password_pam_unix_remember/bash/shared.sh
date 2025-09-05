# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

{{{ bash_instantiate_variables("var_password_pam_unix_remember") }}}

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
        CUSTOM_SYSTEM_AUTH="/etc/authselect/$CURRENT_PROFILE/system-auth"
        CUSTOM_PASSWORD_AUTH="/etc/authselect/$CURRENT_PROFILE/password-auth"
        for custom_pam_file in $CUSTOM_SYSTEM_AUTH $CUSTOM_PASSWORD_AUTH; do
            if ! grep -q "^[^#].*pam_pwhistory.so.*remember=" $custom_pam_file; then
                sed -i --follow-symlinks "/^password.*requisite.*pam_pwquality.so/a password    requisite     pam_pwhistory.so remember=$var_password_pam_unix_remember use_authtok" $custom_pam_file
            else
                sed -i --follow-symlinks "s/\(.*pam_pwhistory.so.*remember=\)[[:digit:]]\+\s\(.*\)/\1$var_password_pam_unix_remember \2/g" $custom_pam_file
            fi
        done
        authselect apply-changes -b --backup=after-pwhistory-hardening.backup
    else
        echo "
authselect integrity check failed. Remediation aborted!
This remediation could not be applied because the authselect profile is not intact.
It is not recommended to manually edit the PAM files when authselect is available
In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
        false
    fi
else
    {{% if product in [ "sle15" ] %}}
    AUTH_FILES[0]="/etc/pam.d/common-password"
    {{% else %}}
    AUTH_FILES[0]="/etc/pam.d/system-auth"
    {{% endif %}}
    AUTH_FILES[1]="/etc/pam.d/password-auth"

    for pamFile in "${AUTH_FILES[@]}"; do
        if grep -q "pam_unix.so.*" $pamFile; then
            {{{ bash_provide_pam_module_options("$pamFile", 'password', 'sufficient', 'pam_unix.so', 'remember', "$var_password_pam_unix_remember", "$var_password_pam_unix_remember") }}}
        fi
        if grep -q "pam_pwhistory.so.*" $pamFile; then
            {{{ bash_provide_pam_module_options("$pamFile", 'password', 'required', 'pam_pwhistory.so', 'remember', "$var_password_pam_unix_remember", "$var_password_pam_unix_remember") }}}
        fi
    done
fi
