# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

{{{ bash_instantiate_variables("var_accounts_passwords_pam_faillock_deny") }}}

if [ -f /usr/sbin/authconfig ]; then
    authconfig --enablefaillock --update
elif [ -f /usr/bin/authselect ]; then
    if [ $(authselect enable-feature with-faillock) ]; then
        authselect apply-changes
    else
        # If authselect can't manage the pam files, mainly due to manual modifications, the current
        # profile will be turned back to a inter state, preserving previously enabled features.
        ENABLED_FEATURES=$(authselect current | tail -n+3 | awk '{ print $2 }')
        CURRENT_PROFILE=$(authselect current -r | awk '{ print $1 }')
        authselect select $CURRENT_PROFILE --force
        for feature in $ENABLED_FEATURES with-faillock; do
            authselect enable-feature $feature;
        done
        authselect apply-changes
    fi
else
    {{{ bash_set_faillock_option("deny", "$var_accounts_passwords_pam_faillock_deny") }}}
fi

# If the faillock.conf file is present, but for any reason, like an OS upgrade, the pam_faillock.so
# parameters were not previously defined in faillock.conf, they are ensured now.
FAILLOCK_CONF="/etc/security/faillock.conf"

if [ -f $FAILLOCK_CONF ]; then
    if $(grep -q '^\s*deny\s*=' $FAILLOCK_CONF); then
        sed -i --follow-symlinks "s/^\s*\(deny\s*\)=.*$/\1 = $var_accounts_passwords_pam_faillock_deny/g" $FAILLOCK_CONF
    else
        echo "deny = $var_accounts_passwords_pam_faillock_deny" >> $FAILLOCK_CONF
    fi
fi
