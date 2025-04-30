#!/bin/bash
# remediation = none
# packages = sssd

CONF="/etc/sssd/sssd.conf"
cat << EOF > "$CONF"
[sssd]
domains = example.com,example2,example3
services = nss, pam
ldap_user_certificate = userCertificate.;binary
certificate_verification = ocsp_dgst=sha1

[domain/example.com]
id_provider = ldap
ldap_uri = ldap://ldap.example.com
ldap_search_base = dc=example,dc=com
ldap_user_certificate = userCertificate;binary
certificate_verification = ocsp_dgst=sha1

[domain/example2]
id_provider = ldap
ldap_uri = ldap://ldap.example2.com
ldap_search_base = dc=example2,dc=com
certificate_verification = ocsp_dgst=sha256

[domain/example3]
id_provider = ldap
ldap_uri = ldap://ldap.example3.com
ldap_search_base = dc=example3,dc=com
ldap_user_certificate = userCertificate;binary
EOF
