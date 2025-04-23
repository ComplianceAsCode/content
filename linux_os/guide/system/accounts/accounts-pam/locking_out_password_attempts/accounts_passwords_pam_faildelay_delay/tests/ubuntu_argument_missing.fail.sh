#!/bin/bash
# platform = multi_platform_ubuntu
# variables = var_password_pam_delay=4000000

config_file=/usr/share/pam-configs/tmp_pwhistory

cat << EOF > /usr/share/pam-configs/tmp_faildelay
Name: Enable faildelay
Conflicts: faildelay
Default: yes
Priority: 512
Auth-Type: Primary
Auth:
    required                   pam_faildelay.so
EOF

DEBIAN_FRONTEND=noninteractive pam-auth-update --enable tmp_faildelay
rm -f /usr/share/pam-configs/tmp_faildelay
