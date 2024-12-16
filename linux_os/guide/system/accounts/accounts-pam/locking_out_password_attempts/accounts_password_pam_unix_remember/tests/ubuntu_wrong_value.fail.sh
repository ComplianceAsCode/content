#!/bin/bash
# platform = multi_platform_ubuntu
# variables = var_password_pam_unix_remember=5

config_file=/usr/share/pam-configs/tmpunix
remember_cnt=3

cat << EOF > "$config_file"
Name: Unix authentication
Default: yes
Priority: 256
Auth-Type: Primary
Auth:
        [success=end default=ignore]    pam_unix.so try_first_pass
Auth-Initial:
        [success=end default=ignore]    pam_unix.so
Account-Type: Primary
Account:
        [success=end new_authtok_reqd=done default=ignore]      pam_unix.so
Account-Initial:
        [success=end new_authtok_reqd=done default=ignore]      pam_unix.so
Session-Type: Additional
Session:
        required        pam_unix.so
Session-Initial:
        required        pam_unix.so
Password-Type: Primary
Password:
        [success=end default=ignore]    pam_unix.so obscure use_authtok try_first_pass yescrypt remember=$remember_cnt
Password-Initial:
        [success=end default=ignore]    pam_unix.so obscure yescrypt remember=$remember_cnt
EOF

DEBIAN_FRONTEND=noninteractive pam-auth-update
rm $config_file
