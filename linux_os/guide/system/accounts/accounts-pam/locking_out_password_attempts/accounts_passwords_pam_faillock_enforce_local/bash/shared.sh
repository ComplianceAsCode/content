# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

SYSTEM_AUTH="/etc/pam.d/system-auth"
PASSWORD_AUTH="/etc/pam.d/password-auth"
FAILLOCK_CONF="/etc/security/faillock.conf"

if [ $(grep -c "^\s*auth.*pam_unix.so" $SYSTEM_AUTH) > 1 ] || \
   [ $(grep -c "^\s*auth.*pam_unix.so" $PASSWORD_AUTH) > 1 ]; then
   echo "Skipping remediation because there are more pam_unix.so entries than expected."
   false
fi

if [ ! $(grep -q '^\s*local_users_only' $FAILLOCK_CONF) ]; then
    echo "local_users_only" >> $FAILLOCK_CONF
fi
authselect enable-feature with-faillock
