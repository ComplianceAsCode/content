#!/bin/bash
# platform = multi_platform_ubuntu

config_file=/usr/share/pam-configs/tmp_pwquality
cat << EOF > "$config_file"
Name: Pwquality password strength checking
Default: yes
Priority: 1025
Conflicts: cracklib, pwquality
Password-Type: Primary
Password:
    requisite                   # pam_pwquality.so
EOF

DEBIAN_FRONTEND=noninteractive pam-auth-update

rm "$config_file"
