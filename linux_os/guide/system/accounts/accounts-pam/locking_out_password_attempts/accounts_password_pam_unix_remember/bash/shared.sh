# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

{{{ bash_instantiate_variables("var_password_pam_unix_remember") }}}

if [ -f /usr/bin/authselect ]; then
    # Ensure a backup before any modification
    authselect apply-changes -b --backup=before-hardening.backup
    # Existing profiles should not be modified, so we create a custom profile if not already in use.
    CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
    if [[ ! $CURRENT_PROFILE == custom/* ]]; then
        ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
        authselect create-profile hardening -b sssd
        CURRENT_PROFILE="custom/hardening"
    fi
    # Include the desired configuration in the custom profile
    CUSTOM_SYSTEM_AUTH="/etc/authselect/$CURRENT_PROFILE/system-auth"
    CUSTOM_PASSWORD_AUTH="/etc/authselect/$CURRENT_PROFILE/password-auth"
    for custom_pam_file in $CUSTOM_SYSTEM_AUTH $CUSTOM_PASSWORD_AUTH; do
        if ! $(grep -q "^[^#].*pam_pwhistory.so.*remember=" $custom_pam_file); then
            sed -i "/^password.*requisite.*pam_pwquality.so/a password    requisite     pam_pwhistory.so remember=$var_password_pam_unix_remember use_authtok" $custom_pam_file
        else
            sed -i "s/\(.*pam_pwhistory.so.*remember=\)[[:digit:]]\+\s\(.*\)/\1$var_password_pam_unix_remember \2/g" $custom_pam_file
        fi
    done
    authselect select $CURRENT_PROFILE --force
    for feature in $ENABLED_FEATURES; do
        authselect enable-feature $feature;
    done
    authselect apply-changes
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
