#!/bin/bash
# packages = authselect
# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

if authselect list-features sssd | grep -q with-silent-lastlog; then
    authselect select sssd --force
    authselect enable-feature with-silent-lastlog
else
    authselect create-profile hardening -b sssd
    CUSTOM_PROFILE="custom/hardening"
    authselect select $CUSTOM_PROFILE --force

    CUSTOM_POSTLOGIN="/etc/authselect/$CUSTOM_PROFILE/postlogin"
    if [ "$(grep -c "^\s*session\s+\[default=1\]\s+pam_lastlog\.so\s+nowtmp\s+showfailed$" $CUSTOM_POSTLOGIN)" -eq 0 ]; then
        sed -i --follow-symlinks '0,/^session.*/s/^session.*/session     [default=1]                pam_lastlog.so nowtmp silent\n&/' $CUSTOM_POSTLOGIN
    fi
fi
authselect apply-changes -b
