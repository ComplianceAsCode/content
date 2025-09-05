#!/bin/bash
# packages = pcsc-lite pam_pkcs11 esc

systemctl enable pcscd.socket
systemctl start pcscd.socket

cat << EOF > "/etc/pam.d/system-auth"
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.
auth        required      pam_env.so
auth        sufficient    pam_unix.so try_first_pass nullok
auth        required      pam_deny.so

account     required      pam_unix.so

password    requisite     pam_pwquality.so try_first_pass local_users_only retry
=3 authtok_type=
password    sufficient    pam_unix.so try_first_pass use_authtok nullok sha512 s
hadow
password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet 
use_uid
session     required      pam_unix.so
EOF

cat << EOF > "/etc/pam.d/smartcard-auth"
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.
auth        required      pam_env.so
auth        [success=done ignore=ignore default=die] pam_pkcs11.so wait_for_card
auth        required      pam_deny.so

account     required      pam_unix.so
account     sufficient    pam_localuser.so
account     sufficient    pam_succeed_if.so uid < 500 quiet
account     required      pam_permit.so

password    optional      pam_pkcs11.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
-session     optional      pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet 
use_uid
session     required      pam_unix.so
EOF
