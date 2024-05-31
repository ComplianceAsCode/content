#!/bin/bash
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora
# remediation = none

SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"

# This modification will break the integrity checks done by authselect.
if ! $(grep -q "^[^#].*pam_pwhistory\.so.*remember=" $SYSTEM_AUTH_FILE); then
	sed -i "/^password.*requisite.*pam_pwquality\.so/a password    requisite     pam_pwhistory.so" $SYSTEM_AUTH_FILE
else
   sed -i "s/\(.*pam_pwhistory\.so.*remember=\)[[:digit:]]\+\s\(.*\)/\1/g" $SYSTEM_AUTH_FILE
fi
