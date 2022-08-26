#!/bin/bash
# packages = authselect,sssd
# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9
# remediation = none

SSSD_FILE="/etc/sssd/sssd.conf"
echo "[pam]" > $SSSD_FILE
echo "pam_cert_auth = True" >> $SSSD_FILE

authselect select sssd --force

SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"
# This modification will break the integrity checks done by authselect.
if ! $(grep -q "^[^#].*pam_pwhistory\.so.*remember=" $SYSTEM_AUTH_FILE); then
	sed -i --follow-symlinks "/^password.*requisite.*pam_pwquality\.so/a password    requisite     pam_pwhistory.so" $SYSTEM_AUTH_FILE
else
   sed -i --follow-symlinks "s/\(.*pam_pwhistory\.so.*remember=\)[[:digit:]]\+\s\(.*\)/\1/g" $SYSTEM_AUTH_FILE
fi
