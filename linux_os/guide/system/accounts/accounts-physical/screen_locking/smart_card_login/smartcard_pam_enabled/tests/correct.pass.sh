#!/bin/bash
# platform = multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu
# packages = libpam-pkcs11

{{% if 'ubuntu' in product %}}
cat << EOF > /usr/share/pam-configs/tmp_pkcs11
Name: Enable pkcs11
Conflicts: pkcs11
Default: yes
Priority: 511
Auth-Type: Primary
Auth:
    [success=end default=ignore]	pam_pkcs11.so
EOF

DEBIAN_FRONTEND=noninteractive pam-auth-update --enable tmp_pkcs11
rm -f /usr/share/pam-configs/tmp_pkcs11
{{% else %}}
echo 'auth sufficient pam_pkcs11.so' > /etc/pam.d/common-auth
{{% endif %}}
