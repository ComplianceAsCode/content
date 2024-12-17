#!/bin/bash
# platform = multi_platform_ubuntu
# variables = var_password_hashing_algorithm_pam=sha512
# remediation = none

config_file=/usr/share/pam-configs/tmpunix
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
        [success=end default=ignore]    pam_unix.so obscure use_authtok try_first_pass # sha512
Password-Initial:
        [success=end default=ignore]    pam_unix.so obscure # sha512
EOF
DEBIAN_FRONTEND=noninteractive pam-auth-update
rm "$config_file"
