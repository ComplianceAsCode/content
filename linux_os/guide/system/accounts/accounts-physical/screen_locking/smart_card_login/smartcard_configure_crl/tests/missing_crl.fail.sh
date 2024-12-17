#!/bin/bash
# platform = multi_platform_ubuntu
# packages = libpam-pkcs11

mkdir -p /etc/pam_pkcs11
echo "# cert_policy = ca,signature,ocsp_on,crl_auto;" > /etc/pam_pkcs11/pam_pkcs11.conf

