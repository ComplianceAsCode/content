#!/bin/bash

SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"

if ! $(grep -q "^[^#].*pam_unix.so.*nullok" $SYSTEM_AUTH_FILE); then
    if [ -f /usr/bin/authselect ]; then
        authselect disable-feature without-nullok
        authselect apply-changes
    else
        sed -i 's/\([\s].*pam_unix.so.*\)\s\(try_first_pass.*\)/\1nullok \2/' $SYSTEM_AUTH_FILE
    fi
fi
