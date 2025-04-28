#!/bin/bash
# remediation = none
cat >> /etc/sssd/sssd.conf<< EOF
ldap_user_certificate = userCertificate;binary
EOF
