#!/bin/bash
# platform = Oracle Linux 7,Red Hat Virtualization 4,multi_platform_fedora

pam_file="/etc/pam.d/password-auth"

if ! grep -q "^password.*sufficient.*pam_unix\.so.*sha512" "$pam_file"; then
	sed -i --follow-symlinks '/^password.*sufficient.*pam_unix\.so/ s/$/ sha512/' "$pam_file"
fi
