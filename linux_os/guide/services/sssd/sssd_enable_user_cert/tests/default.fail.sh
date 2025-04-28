#!/bin/bash
# remediation = none

touch /etc/sssd/sssd.conf
sed -i "s/ldap_user_certificate.*//g" /etc/sssd/sssd.conf
