#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora
# remediation = none

SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"

# This modification will break the current authselect profile and will be detected by the
# authselect integrity check, aborting the remediation and showing an informative message
# in the remediation report.
if ! $(grep -q "^[^#].*pam_unix.so.*nullok" $SYSTEM_AUTH_FILE); then
   sed -i 's/\([\s].*pam_unix.so.*\)\s\(try_first_pass.*\)/\1nullok \2/' $SYSTEM_AUTH_FILE
fi
