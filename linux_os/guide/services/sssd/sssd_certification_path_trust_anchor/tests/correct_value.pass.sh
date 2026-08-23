#!/bin/bash
# packages = sssd-common

mkdir -p /etc/sssd/conf.d
touch /etc/sssd/sssd.conf
echo -e "$ sudo vi /etc/sssd/sssd.conf
[sssd]
services = nss,pam,ssh
config_file_version = 2

[pam]
pam_cert_auth = True

[domain/example.com]
ldap_user_certificate = usercertificate;binary
certificate_verification = ca_cert,ocsp
ca_cert = /etc/ssl/certs/ca-certificates.crt
" >> /etc/sssd/sssd.conf
