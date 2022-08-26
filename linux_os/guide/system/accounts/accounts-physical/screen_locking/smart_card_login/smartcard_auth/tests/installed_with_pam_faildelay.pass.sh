#!/bin/bash
# packages = pcsc-lite pam_pkcs11 esc

systemctl enable pcscd.socket
systemctl start pcscd.socket

. ./configure_pam_stack.sh

# Add pam_faildelay line to system-auth
PAM_ENV_SO="auth.*required.*pam_env\.so"
sed -i --follow-symlinks '/auth.*required.*pam_env\.so/ a auth        required                                     pam_faildelay.so delay=2000000' /etc/pam.d/system-auth
