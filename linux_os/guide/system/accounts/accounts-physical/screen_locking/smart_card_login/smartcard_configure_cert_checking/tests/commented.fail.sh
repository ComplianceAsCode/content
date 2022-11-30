#!/bin/bash
# platform = multi_platform_ubuntu,multi_platform_rhel
# packages = openssl-pkcs11

if [ ! -f /etc/pam_pkcs11/pam_pkcs11.conf ]; then
    cp /usr/share/doc/libpam-pkcs11/examples/pam_pkcs11.conf.example /etc/pam_pkcs11/pam_pkcs11.conf
fi

sed -i "/^\s*#/! s/cert_policy.*/# cert_policy = ca,signature,ocsp_on;/g" /etc/pam_pkcs11/pam_pkcs11.conf
