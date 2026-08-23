#!/bin/bash
# platform = multi_platform_ubuntu
# packages = pam

config_file=/usr/share/pam-configs/tmp_pwhistory

cat << EOF > "$config_file"
Name: pwhistory password history checking
Default: yes
Priority: 1024
Password-Type: Primary
Password: requisite pam_pwhistory.so remember=24 enforce_for_root try_first_pass
EOF

DEBIAN_FRONTEND=noninteractive pam-auth-update --enable tmp_pwhistory
rm "$config_file"
