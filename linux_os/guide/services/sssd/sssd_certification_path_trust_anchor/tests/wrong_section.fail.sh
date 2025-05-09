#!/bin/bash
# packages = sssd-common

mkdir -p /etc/sssd/conf.d
touch /etc/sssd/sssd.conf
echo -e "[sssd]\ncertificate_verification = ca_cert,ocsp" >> /etc/sssd/sssd.conf
