#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

. ../setup_config_files.sh
setup_correct_sssd_config

sed -i '/\[domain/d' /etc/sssd/sssd.conf
