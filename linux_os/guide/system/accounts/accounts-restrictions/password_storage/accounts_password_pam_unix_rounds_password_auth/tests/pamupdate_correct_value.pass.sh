#!/bin/bash
# platform = multi_platform_ubuntu
# packages = pam
# variables = var_password_pam_unix_rounds=65536

ROUNDS=65536

config_file=/usr/share/pam-configs/tmp_unix

cat << EOF > "$config_file"
Name: Unix authentication
Default: yes
Priority: 257
Conflicts: unix
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
        [success=end default=ignore]    pam_unix.so obscure sha512 shadow remember=5 rounds=$ROUNDS
Password-Initial:
        [success=end default=ignore]    pam_unix.so obscure sha512 shadow remember=5 rounds=$ROUNDS
EOF

DEBIAN_FRONTEND=noninteractive pam-auth-update
rm $config_file
