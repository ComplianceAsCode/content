#!/bin/bash
# platform = multi_platform_ubuntu,multi_platform_rhel
{{% if "ubuntu" in product %}}
# packages = libpam-pkcs11
{{% elif "rhel7" == product %}}
# packages = pam_pkcs11
{{% else %}}
# packages = openssl-pkcs11
{{% endif %}}

if [ ! -f /etc/pam_pkcs11/pam_pkcs11.conf ]; then
    cp /usr/share/doc/libpam-pkcs11/examples/pam_pkcs11.conf.example /etc/pam_pkcs11/pam_pkcs11.conf
fi

sed -i "/^\s*#/! s/cert_policy.*/# cert_policy = ca,signature,ocsp_on;/g" /etc/pam_pkcs11/pam_pkcs11.conf
