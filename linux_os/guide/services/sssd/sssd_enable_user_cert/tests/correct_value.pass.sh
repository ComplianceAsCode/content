#!/bin/bash
# packages = sssd

CONF="/etc/sssd/sssd.conf"
echo -e "[domain/LDAP]\nldap_user_certificate = userCertificate;binary" > "$CONF"
