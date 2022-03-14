# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

{{{ bash_enable_pam_faillock_with_authselect() }}}

FAILLOCK_CONF="/etc/security/faillock.conf"
if [ -f $FAILLOCK_CONF ]; then
    if ! grep -q '^\s*local_users_only' $FAILLOCK_CONF; then
        echo "local_users_only" >> $FAILLOCK_CONF
    fi
fi
