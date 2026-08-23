#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_almalinux
# remediation = none

mv /etc/pam.d/system-auth /etc/pam.d/system-auth-ac
mv /etc/pam.d/password-auth /etc/pam.d/password-auth-ac

cat << EOF > /etc/pam.d/system-auth-mycustomconfig
auth        required      pam_faillock.so preauth silent audit deny=3 even_deny_root fail_interval=900 unlock_time=900
auth        include       system-auth-ac
auth        sufficient    pam_unix.so try_first_pass
auth        [default=die] pam_faillock.so authfail audit deny=3 even_deny_root fail_interval=900 unlock_time=900

account     required      pam_faillock.so
account     include       system-auth-ac

password    requisite     pam_pwhistory.so use_authtok remember=5 retry=3
password    include       system-auth-ac
password    sufficient    pam_unix.so sha512 shadow try_first_pass use_authtok

session     include       system-auth-ac
EOF

cat << EOF > /etc/pam.d/password-auth-mycustomconfig
auth        required      pam_faillock.so preauth silent audit deny=3 even_deny_root fail_interval=900 unlock_time=900
auth        include       password-auth-ac
auth        sufficient    pam_unix.so try_first_pass
auth        [default=die] pam_faillock.so authfail audit deny=3 even_deny_root fail_interval=900 unlock_time=900

account     required      pam_faillock.so
account     include       password-auth-ac

password    requisite     pam_pwhistory.so use_authtok remember=5 retry=3
password    include       password-auth-ac
password    sufficient    pam_unix.so sha512 shadow try_first_pass use_authtok

session     include       password-auth-ac
EOF

ln -sf /etc/pam.d/system-auth-mycustomconfig /etc/pam.d/system-auth
ln -sf /etc/pam.d/password-auth-mycustomconfig /etc/pam.d/password-auth
