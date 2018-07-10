#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa
# remediation = bash

. ../setup_config_files.sh
setup_correct_sssd_config

sed -i 's/ldap_id_use_start_tls.*/ldap_id_use_start_tls = folder/' /etc/sssd/sssd.conf
