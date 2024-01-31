#!/bin/bash
# packages = /usr/lib/systemd/system/sssd.service

. $SHARED/setup_config_files.sh
setup_correct_sssd_config

systemctl enable sssd

mkdir -p /etc/sssd/conf.d/

sed -i '/ldap_id_use_start_tls/d' /etc/sssd/sssd.conf

cat > "/etc/sssd/conf.d/unused.conf" << EOF
[domain/default]

ldap_id_use_start_tls = True
id_provider = ldap
autofs_provider = ldap
auth_provider = krb5
chpass_provider = krb5
ldap_search_base = dc=com
ldap_tls_cacertdir = /etc/openldap/cacerts
cache_credentials = True
krb5_store_password_if_offline = True
ldap_tls_reqcert = demand
EOF

