#!/bin/bash
# remediation = none
# packages = sssd

CONF="/etc/sssd/sssd.conf"
echo -e "[domain/LDAP]\n#ldap_user_certificate = userCertificate;binary" > "$CONF"
