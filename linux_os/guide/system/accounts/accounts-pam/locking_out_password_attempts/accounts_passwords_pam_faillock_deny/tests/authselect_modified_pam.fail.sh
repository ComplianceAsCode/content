#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora

SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"

# This modification will break the integrity checks done by authselect. The remediation
# should be robust enough to deal with possible manual and unvalidated modification.
if ! $(grep -q "^[^#].*pam_pwhistory.so.*remember=" $SYSTEM_AUTH_FILE); then
	sed -i "/^password.*requisite.*pam_pwquality.so/a password    requisite     pam_pwhistory.so" $SYSTEM_AUTH_FILE
else
   sed -i "s/\(.*pam_pwhistory.so.*remember=\)[[:digit:]]\+\s\(.*\)/\1/g" $SYSTEM_AUTH_FILE
fi
