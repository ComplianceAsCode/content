#!/bin/bash
# platform = multi_platform_ubuntu,multi_platform_sle
# packages = libpam-pkcs11

{{% if 'ubuntu' in product %}}
echo 'aauth [success=2 default=ignore] pam_pkcs11.so' > /etc/pam.d/common-auth
{{% else %}}
echo 'aauth sufficient pam_pkcs11.so' > /etc/pam.d/common-auth
{{% endif %}}
