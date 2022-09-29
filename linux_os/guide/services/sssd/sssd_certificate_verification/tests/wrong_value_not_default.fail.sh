#!/bin/bash
# packages = sssd-common
# variables = var_sssd_certificate_verification_digest_function=sha512

mkdir -p /etc/sssd/conf.d
touch /etc/sssd/sssd.conf
echo -e "[sssd]\ncertificate_verification = ocsp_dgst=sha256" >> /etc/sssd/sssd.conf

