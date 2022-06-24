# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = medium

{{{ bash_ensure_ini_config("/etc/sssd/sssd.conf", "pam", "pam_cert_auth", "true") }}}

{{% if product in ["ol8", "rhel8"] %}}
if [ -f /usr/bin/authselect ]; then
    if authselect check; then
        {{% if product in ["ol8"] %}}
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
        CUSTOM_PROFILE_DIR="/etc/authselect/$CURRENT_PROFILE"
        # The line should be included on the top of postlogin file
        
        {{{ bash_ensure_pam_module_options("$CUSTOM_PROFILE_DIR/smartcard-auth",
                                           'auth',
                                           'sufficient',
                                           'pam_sss.so',
                                           'try_cert_auth', '', '') }}}
        {{{ bash_ensure_pam_module_options("$CUSTOM_PROFILE_DIR/system-auth",
                                           'auth',
                                           'sufficient', 
                                           'pam_sss.so',
                                           'try_cert_auth', '', '') }}}
        {{% else %}}
        authselect enable-feature with-smartcard
        {{% endif %}}
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
    {{{ bash_ensure_pam_module_options('/etc/pam.d/smartcard-auth', 'auth', 'sufficient', 'pam_sss.so', 'try_cert_auth', '', '') }}}
    {{{ bash_ensure_pam_module_options('/etc/pam.d/system-auth', 'auth', 'sufficient', 'pam_sss.so', 'try_cert_auth', '', '') }}}
fi
{{% endif %}}

