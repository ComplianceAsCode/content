#!/bin/bash

. $SHARED/setup_config_files.sh
setup_correct_sssd_config

mkdir -p /etc/sssd/conf.d/

cat > "/etc/sssd/conf.d/unused.conf" << EOF
[domain/default]

ldap_id_use_start_tls = never
EOF
