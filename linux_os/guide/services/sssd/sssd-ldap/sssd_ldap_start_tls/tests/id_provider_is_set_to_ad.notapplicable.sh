#!/bin/bash
# packages = /usr/lib/systemd/system/sssd.service

. $SHARED/setup_config_files.sh
setup_correct_sssd_config

systemctl enable sssd

sed -i 's/id_provider = ldap/id_provider = ad/I' /etc/sssd/sssd.conf
