# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

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

FAILLOCK_CONF="/etc/security/faillock.conf"
if [ -f $FAILLOCK_CONF ]; then
    if ! grep -q '^\s*local_users_only' $FAILLOCK_CONF; then
        echo "local_users_only" >> $FAILLOCK_CONF
    fi
fi
