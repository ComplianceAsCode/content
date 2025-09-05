#!/bin/bash
# platform = Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol

SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"

if ! $(grep -q "^[^#].*pam_unix.so.*nullok" $SYSTEM_AUTH_FILE); then
    sed -i 's/\([\s].*pam_unix.so.*\)\s\(try_first_pass.*\)/\1nullok \2/' $SYSTEM_AUTH_FILE
fi
