#!/bin/bash
# platform = multi_platform_ubuntu

cat << EOF > /usr/share/pam-configs/tmp_faillock
Name: Enable pam_faillock to deny access
Default: yes
Priority: 0
Auth-Type: Primary
Auth:
    [default=die]                   pam_faillock.so authfail silent
    sufficient                      pam_faillock.so authsucc silent
EOF

cat << EOF > /usr/share/pam-configs/tmp_faillock_notify
Name: Notify of failed login attempts and reset count upon success
Default: yes
Priority: 1024
Auth-Type: Primary
Auth:
    requisite                       pam_faillock.so preauth silent
Account-Type: Primary
Account:
    required                        pam_faillock.so
EOF

DEBIAN_FRONTEND=noninteractive pam-auth-update
rm /usr/share/pam-configs/tmp_faillock /usr/share/pam-configs/tmp_faillock_notify
