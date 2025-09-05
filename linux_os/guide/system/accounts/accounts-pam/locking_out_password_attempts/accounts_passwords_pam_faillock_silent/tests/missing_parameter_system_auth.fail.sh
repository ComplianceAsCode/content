#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

source common.sh

if ! grep -q "pam_faillock\.so.*silent" "$CUSTOM_PROFILE_DIR/password-auth" ; then
    sed -i --follow-symlinks "/pam_faillock\.so/s/preauth/preauth silent/" \
    "$CUSTOM_PROFILE_DIR/password-auth"
fi

authselect apply-changes
