# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

{{{ bash_instantiate_variables("var_accounts_passwords_pam_faillock_deny") }}}

if [ -f /usr/sbin/authconfig ]; then
    authconfig --enablefaillock --update
elif [ -f /usr/bin/authselect ]; then
    if authselect check; then
        authselect enable-feature with-faillock
        authselect apply-changes
    else
        echo "
authselect integrity check failed. Remediation aborted!
This remediation could not be applied because the authselect profile is not intact.
It is not recommended to manually edit the PAM files when authselect is available
In cases where the default authselect profile does not cover a specific demand, a custom authselect profile is recommended."
        false
    fi
fi

FAILLOCK_CONF="/etc/security/faillock.conf"
if [ -f $FAILLOCK_CONF ]; then
    if $(grep -q '^\s*deny\s*=' $FAILLOCK_CONF); then
        sed -i --follow-symlinks "s/^\s*\(deny\s*\)=.*$/\1 = $var_accounts_passwords_pam_faillock_deny/g" $FAILLOCK_CONF
    else
        echo "deny = $var_accounts_passwords_pam_faillock_deny" >> $FAILLOCK_CONF
    fi
else
    {{{ bash_set_faillock_option("deny", "$var_accounts_passwords_pam_faillock_deny") }}}
fi
