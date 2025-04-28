#!/bin/bash
# remediation = none
# packages = sssd

touch /etc/sssd/sssd.conf
sed -i "s/ldap_user_certificate.*//g" /etc/sssd/sssd.conf
