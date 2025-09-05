#!/bin/bash
# platform = multi_platform_ubuntu,multi_platform_sle
# packages = libpam-pkcs11
{{% if 'ubuntu' in product %}}
sed -i '/^auth.*pam_unix.so/i # auth [success=2 default=ignore] pam_pkcs11.so' /etc/pam.d/common-auth
{{% else %}}
echo '# auth sufficient pam_pkcs11.so' > /etc/pam.d/common-auth
{{% endif %}}
