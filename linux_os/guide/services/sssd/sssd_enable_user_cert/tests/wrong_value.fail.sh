#!/bin/bash
# remediation = none
# packages = sssd

CONF="/etc/sssd/sssd.conf"
echo -e "[domain/LDAP]\nldap_user_certificate = default" > "$CONF"
