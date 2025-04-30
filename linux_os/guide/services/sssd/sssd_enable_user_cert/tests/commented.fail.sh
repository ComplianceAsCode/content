#!/bin/bash
# remediation = none

CONF="/etc/sssd/sssd.conf"
echo -e "[domain/LDAP]\n#ldap_user_certificate = userCertificate;binary" > "$CONF"
