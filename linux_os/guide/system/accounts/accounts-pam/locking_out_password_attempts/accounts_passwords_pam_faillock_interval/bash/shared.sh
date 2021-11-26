# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

{{{ bash_instantiate_variables("var_accounts_passwords_pam_faillock_fail_interval") }}}

if [ $(grep -c "^\s*auth.*pam_unix.so" /etc/pam.d/system-auth) > 1 ] || \
   [ $(grep -c "^\s*auth.*pam_unix.so" /etc/pam.d/password-auth) > 1 ]; then
   echo "Skipping remediation because there are more pam_unix.so entries than expected."
   false
fi

if [ -f /etc/security/faillock.conf ]; then
    if $(grep -q '^\s*fail_interval\s*=' /etc/security/faillock.conf); then
        sed -i --follow-symlinks "s/^\s*\(fail_interval\s*\)=.*$/\1 = $var_accounts_passwords_pam_faillock_fail_interval/g" /etc/security/faillock.conf
    else
        echo "fail_interval = $var_accounts_passwords_pam_faillock_fail_interval" >> /etc/security/faillock.conf
    fi
    # If the faillock.conf file is present, but for any reason, like an OS upgrade, the
    # pam_faillock.so parameters are still defined in pam files, this make them compatible with
    # the newer versions of authselect tool and ensure the parameters are only in faillock.conf.
    sed -i --follow-symlinks 's/\(pam_faillock.so preauth\).*$/\1 silent/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
    sed -i --follow-symlinks 's/\(pam_faillock.so authfail\).*$/\1/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
    authselect enable-feature with-faillock
else
    if [ -f /usr/sbin/authconfig ]; then
        authconfig --enablefaillock --update
    else
        authselect enable-feature with-faillock
    fi
    {{{ bash_set_faillock_option("fail_interval", "$var_accounts_passwords_pam_faillock_fail_interval") }}}
fi
