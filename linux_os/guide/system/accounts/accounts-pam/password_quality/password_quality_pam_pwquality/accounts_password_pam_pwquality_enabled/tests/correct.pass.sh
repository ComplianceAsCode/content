#!/bin/bash
# platform = multi_platform_ubuntu

cat << EOF > /usr/share/pam-configs/pwquality
Name: Pwquality password strength checking
Default: yes
Priority: 1024
Conflicts: cracklib
Password-Type: Primary
Password:
    requisite                   pam_pwquality.so
EOF

DEBIAN_FRONTEND=noninteractive pam-auth-update
