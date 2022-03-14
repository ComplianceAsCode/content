# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

if [ -f /usr/bin/authselect ]; then
    {{{ bash_enable_pam_faillock_with_authselect() }}}
fi

FAILLOCK_CONF="/etc/security/faillock.conf"
if [ -f $FAILLOCK_CONF ]; then
    if ! grep -q '^\s*even_deny_root' $FAILLOCK_CONF; then
        echo "even_deny_root" >> $FAILLOCK_CONF
    fi
else
    SYSTEM_AUTH="/etc/pam.d/system-auth"
    PASSWORD_AUTH="/etc/pam.d/password-auth"
    for file in $SYSTEM_AUTH $PASSWORD_AUTH; do
        if ! grep -q "^auth.*pam_faillock.so \(preauth silent\|authfail\).*even_deny_root" $file; then
			sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\).*\)$/\1 even_deny_root/g' $file
		fi
    done
fi
