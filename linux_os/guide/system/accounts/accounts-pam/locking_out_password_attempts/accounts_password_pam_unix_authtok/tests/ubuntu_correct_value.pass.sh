#!/bin/bash
# platform = multi_platform_ubuntu

source ubuntu_common.sh

config_file=/usr/share/pam-configs/tmpunix

# lower priority to ensure the config is below the cac_test_echo
# on the stack, thus using the "Password:" configuration
cat << EOF > "$config_file"
Name: Unix authentication
Default: yes
Priority: 1024
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
        [success=end default=ignore]    pam_unix.so obscure use_authtok try_first_pass yescrypt 
Password-Initial:
        [success=end default=ignore]    pam_unix.so obscure yescrypt 
EOF

DEBIAN_FRONTEND=noninteractive pam-auth-update
rm "$config_file"
