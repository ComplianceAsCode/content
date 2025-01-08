#!/bin/bash
# platform = multi_platform_ubuntu
# packages = pam

# Multiple instances of pam_unix.so in auth section may, intentionally or not, interfere
# in the expected behaviour of pam_faillock.so. Remediation does not solve this automatically
# in order to preserve intentional changes.
cat << EOF > /usr/share/pam-configs/tmp_unix
Name: Unix authentication
Default: yes
Priority: 257
Auth-Type: Primary
Auth:
        [success=end default=ignore]    pam_unix.so nullok try_first_pass
Auth-Initial:
        [success=end default=ignore]    pam_unix.so nullok
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
        auth        sufficient       pam_unix.so
EOF
DEBIAN_FRONTEND=noninteractive pam-auth-update

rm -f /usr/share/pam-configs/tmp_unix
