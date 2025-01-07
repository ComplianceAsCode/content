#!/bin/bash
# platform = multi_platform_ubuntu
# packages = pam
# variables = var_password_pam_remember=5

config_file=/usr/share/pam-configs/tmp_pwhistory

cat << EOF > "$config_file"
Name: pwhistory password history checking
Default: yes
Priority: 1024
Password-Type: Primary
Password: requisite pam_pwhistory.so enforce_for_root try_first_pass use_authtok
EOF

DEBIAN_FRONTEND=noninteractive pam-auth-update --enable tmp_pwhistory
rm "$config_file"
