#!/bin/bash

. $SHARED/setup_config_files.sh
setup_correct_sssd_config
sed -i '/ldap_tls_reqcert/d' /etc/sssd/sssd.conf
