#!/bin/bash
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ubuntu

{{% if 'ubuntu' in product %}}
sed -i --follow-symlinks '/^\s*password.*pam_unix\.so/ s/sha512//g' "/etc/pam.d/common-password"
{{% else %}}
sed -i --follow-symlinks '/^password.*sufficient.*pam_unix\.so/ s/sha512//g' "/etc/pam.d/system-auth"
{{% endif %}}
