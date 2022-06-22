#!/bin/bash
# packages = authselect
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora
# remediation = none

PASSWORD_AUTH_FILE="/etc/pam.d/password-auth"

# This modification will break the integrity checks done by authselect.
sed -i --follow-symlinks '/^password.*sufficient.*pam_unix.so/ s/sha512//g' $PASSWORD_AUTH_FILE
echo "session     optional    pam_unix.so" >> $PASSWORD_AUTH_FILE
