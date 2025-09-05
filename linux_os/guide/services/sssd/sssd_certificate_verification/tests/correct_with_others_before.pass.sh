#!/bin/bash
# packages = sssd-common

mkdir -p /etc/sssd/conf.d
touch /etc/sssd/sssd.conf
echo -e "[sssd]\ndifferent_option = test\ncertificate_verification = ocsp_dgst=sha1" >> /etc/sssd/sssd.conf
