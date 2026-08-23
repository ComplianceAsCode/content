#!/bin/bash
# platform = Oracle Linux 7,Red Hat Virtualization 4,multi_platform_fedora

pam_file="/etc/pam.d/password-auth"

if [ $(grep -c "^\s*password.*requisite.*pam_pwquality\.so" $pam_file) -eq 0 ]; then
	sed -i --follow-symlinks "/^account.*required.*pam_permit\.so/a password    optional     pam_pwquality.so" "$pam_file"
else
	sed -r -i --follow-symlinks "s/(^password.*)(required|requisite)(.*pam_pwquality\.so.*)$/\1optional\3/" "$pam_file"
fi
