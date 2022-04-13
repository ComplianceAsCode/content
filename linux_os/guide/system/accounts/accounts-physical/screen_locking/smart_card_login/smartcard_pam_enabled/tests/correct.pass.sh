#!/bin/bash
# platform = multi_platform_ubuntu,multi_platform_sle
# packages = libpam-pkcs11

{{% if product in ["ubuntu1604", "ubuntu1804", "ubuntu2004"] %}}
echo 'auth [success=2 default=ignore] pam_pkcs11.so' > /etc/pam.d/common-auth
{{% else %}}
echo 'auth sufficient pam_pkcs11.so' > /etc/pam.d/common-auth
{{% endif %}}
