#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora

SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"

authselect select sssd --force
if ! $(grep -q "^[^#].*pam_unix\.so.*nullok" $SYSTEM_AUTH_FILE); then
    authselect disable-feature without-nullok
    authselect apply-changes
fi
