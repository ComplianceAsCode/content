#!/bin/bash
# packages = /usr/lib/systemd/system/sssd.service

. $SHARED/setup_config_files.sh
setup_correct_sssd_config

sed -i '/ldap_id_use_start_tls/d' /etc/sssd/sssd.conf

echo '[domain/default]' >> /etc/sssd/conf.d/cac.conf
echo 'ldap_id_use_start_tls = True' >> /etc/sssd/conf.d/cac.conf
systemctl enable sssd
