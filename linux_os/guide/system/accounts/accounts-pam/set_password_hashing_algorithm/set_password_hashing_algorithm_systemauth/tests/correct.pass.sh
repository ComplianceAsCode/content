#!/bin/bash
# platform = Oracle Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ubuntu

{{% if 'ubuntu' in product %}}
pam_file="/etc/pam.d/common-password"

if ! grep -q "^\s*password.*pam_unix\.so.*sha512" "$pam_file"; then
	sed -i --follow-symlinks '/^\s*password.*pam_unix\.so/ s/$/ sha512/' "$pam_file"
fi
{{% else %}}
pam_file="/etc/pam.d/system-auth"

if ! grep -q "^password.*sufficient.*pam_unix\.so.*sha512" "$pam_file"; then
	sed -i --follow-symlinks '/^password.*sufficient.*pam_unix\.so/ s/$/ sha512/' "$pam_file"
fi
{{% endif %}}
