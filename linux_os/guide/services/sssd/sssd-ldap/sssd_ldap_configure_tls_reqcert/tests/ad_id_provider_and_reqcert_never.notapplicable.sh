#!/bin/bash

. $SHARED/setup_config_files.sh
setup_correct_sssd_config
sed -i 's/ldap_tls_reqcert = demand/ldap_id_use_start_tls = never/' /etc/sssd/sssd.conf
sed -i 's/id_provider = ldap/id_provider = ad/' /etc/sssd/sssd.conf
