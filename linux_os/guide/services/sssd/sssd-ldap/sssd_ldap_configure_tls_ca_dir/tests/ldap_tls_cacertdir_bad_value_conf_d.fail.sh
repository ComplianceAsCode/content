#!/bin/bash
# packages = /usr/lib/systemd/system/sssd.service

. $SHARED/setup_config_files.sh
setup_correct_sssd_config

systemctl enable sssd

mkdir -p /etc/sssd/conf.d/

cat > "/etc/sssd/conf.d/unused.conf" << EOF
[domain/default]

ldap_tls_cacertdir = /tmp/etc/openldap/cacerts
EOF
