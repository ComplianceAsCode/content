#!/bin/bash
# platform = Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol

pam_file="/etc/pam.d/password-auth"

if [ $(grep -c "^\s*password.*requisite.*pam_pwquality\.so" $pam_file) -eq 0 ]; then
	sed -i --follow-symlinks "/^account.*required.*pam_permit\.so/a password    optional     pam_pwquality.so" "$pam_file"
else
	sed -r -i --follow-symlinks "s/(^password.*)(required|requisite)(.*pam_pwquality\.so.*)$/\1optional\3/" "$pam_file"
fi
