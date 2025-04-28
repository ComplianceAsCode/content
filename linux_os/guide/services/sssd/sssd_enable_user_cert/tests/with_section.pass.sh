#!/bin/bash
# remediation = none
# packages = sssd

cat >> /etc/sssd/sssd.conf<< EOF
ldap_user_certificate = userCertificate;binary
EOF
