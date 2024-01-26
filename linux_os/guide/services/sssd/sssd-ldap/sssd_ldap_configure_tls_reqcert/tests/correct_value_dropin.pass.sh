#!/bin/bash
# packages = /usr/lib/systemd/system/sssd.service

. $SHARED/setup_config_files.sh
setup_correct_sssd_config

sed -i '/ldap_tls_reqcert/d' /etc/sssd/sssd.conf

echo '[domain/default]' >> /etc/sssd/conf.d/cac.conf
echo 'ldap_tls_reqcert = demand' >> /etc/sssd/conf.d/cac.conf
systemctl enable sssd
