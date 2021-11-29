# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

{{{ bash_instantiate_variables("var_accounts_passwords_pam_faillock_unlock_time") }}}

SYSTEM_AUTH="/etc/pam.d/system-auth"
PASSWORD_AUTH="/etc/pam.d/password-auth"
FAILLOCK_CONF="/etc/security/faillock.conf"

if [ $(grep -c "^\s*auth.*pam_unix.so" $SYSTEM_AUTH) > 1 ] || \
   [ $(grep -c "^\s*auth.*pam_unix.so" $PASSWORD_AUTH) > 1 ]; then
   echo "Skipping remediation because there are more pam_unix.so entries than expected."
   false
fi

if [ -f $FAILLOCK_CONF ]; then
    if $(grep -q '^\s*unlock_time\s*=' $FAILLOCK_CONF); then
        sed -i --follow-symlinks "s/^\s*\(unlock_time\s*\)=.*$/\1 = $var_accounts_passwords_pam_faillock_unlock_time/g" $FAILLOCK_CONF
    else
        echo "unlock_time = $var_accounts_passwords_pam_faillock_unlock_time" >> $FAILLOCK_CONF
    fi
    # If the faillock.conf file is present, but for any reason, like an OS upgrade, the
    # pam_faillock.so parameters are still defined in pam files, this makes them compatible with
    # the newer versions of authselect tool and ensure the parameters are only in faillock.conf.
    sed -i --follow-symlinks 's/\(pam_faillock.so preauth\).*$/\1 silent/g' $SYSTEM_AUTH $PASSWORD_AUTH
    sed -i --follow-symlinks 's/\(pam_faillock.so authfail\).*$/\1/g' $SYSTEM_AUTH $PASSWORD_AUTH
    authselect enable-feature with-faillock
else
    if [ -f /usr/sbin/authconfig ]; then
        authconfig --enablefaillock --update
    else
        authselect enable-feature with-faillock
    fi
    {{{ bash_set_faillock_option("unlock_time", "$var_accounts_passwords_pam_faillock_unlock_time") }}}
fi
