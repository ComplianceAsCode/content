#!/bin/bash

. $SHARED/setup_config_files.sh
setup_correct_sssd_config
enable_and_start_service
sed -i '/ldap_tls_reqcert/d' /etc/sssd/sssd.conf
