#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora
# remediation = none

SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"

# This modification will break the integrity checks done by authselect.
sed -i --follow-symlinks '/^password.*sufficient.*pam_unix\.so/ s/sha512//g' $SYSTEM_AUTH_FILE
echo "session     optional    pam_unix.so" >> $SYSTEM_AUTH_FILE
