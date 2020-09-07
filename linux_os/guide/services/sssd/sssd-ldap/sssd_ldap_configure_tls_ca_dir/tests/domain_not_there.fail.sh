#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

. $SHARED/setup_config_files.sh
setup_correct_sssd_config

yum -y install /usr/lib/systemd/system/sssd.service
systemctl enable sssd

sed -i '/\[domain/d' /etc/sssd/sssd.conf
