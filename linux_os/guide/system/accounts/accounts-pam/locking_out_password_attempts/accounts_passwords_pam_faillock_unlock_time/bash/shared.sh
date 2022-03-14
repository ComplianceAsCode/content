# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

{{{ bash_instantiate_variables("var_accounts_passwords_pam_faillock_unlock_time") }}}

if [ -f /usr/bin/authselect ]; then
    {{{ bash_enable_pam_faillock_with_authselect() }}}
fi

FAILLOCK_CONF="/etc/security/faillock.conf"
if [ -f $FAILLOCK_CONF ]; then
    if grep -q '^\s*unlock_time\s*=' $FAILLOCK_CONF; then
        sed -i --follow-symlinks "s/^\s*\(unlock_time\s*\)=.*$/\1 = $var_accounts_passwords_pam_faillock_unlock_time/g" $FAILLOCK_CONF
    else
        echo "unlock_time = $var_accounts_passwords_pam_faillock_unlock_time" >> $FAILLOCK_CONF
    fi
else
    {{{ bash_set_faillock_option("unlock_time", "$var_accounts_passwords_pam_faillock_unlock_time") }}}
fi
