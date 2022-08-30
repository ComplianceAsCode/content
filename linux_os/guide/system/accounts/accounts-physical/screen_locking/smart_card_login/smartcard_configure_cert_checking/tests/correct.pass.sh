#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_ubuntu
{{% if "ubuntu" in product %}}
# packages = libpam-pkcs11
{{% elif product in ["ol7", "rhel7"] %}}
# packages = pam_pkcs11
{{% else %}}
# packages = openssl-pkcs11
{{% endif %}}

if [ ! -f /etc/pam_pkcs11/pam_pkcs11.conf ]; then
    cp /usr/share/doc/libpam-pkcs11/examples/pam_pkcs11.conf.example /etc/pam_pkcs11/pam_pkcs11.conf
fi

if grep -v "^\s*\#+cert_policy" /etc/pam_pkcs11/pam_pkcs11.conf | grep -qv "oscp_on"; then
    sed -i "s/\(^[[:blank:]]*\)\(\(\#*[[:blank:]]*cert_policy[[:blank:]]*=[[:blank:]]*.*;\)[^ $]*\)/\1cert_policy = ca,signature,ocsp_on;/" /etc/pam_pkcs11/pam_pkcs11.conf
fi
