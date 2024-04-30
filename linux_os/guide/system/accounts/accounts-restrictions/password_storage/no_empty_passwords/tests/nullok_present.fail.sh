#!/bin/bash
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ubuntu

{{% if 'ubuntu' in product %}}
for FILE in "/etc/pam.d/common-password"; do
    if ! grep -q "^[^#].*pam_unix\.so.*nullok" ${FILE}; then
        sed -i 's/\([\s]pam_unix\.so\)/\1 nullok/g' ${FILE}
    fi
done
{{% else %}}
SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"

if ! $(grep -q "^[^#].*pam_unix\.so.*nullok" $SYSTEM_AUTH_FILE); then
    sed -i --follow-symlinks 's/\([\s].*pam_unix\.so.*\)\s\(try_first_pass.*\)/\1nullok \2/' $SYSTEM_AUTH_FILE
fi
{{% endif %}}

