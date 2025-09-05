#!/bin/bash
# packages = pcsc-lite pam_pkcs11 esc

systemctl enable pcscd.socket
systemctl start pcscd.socket

. ./configure_pam_stack.sh


SMARTCARD_AUTH_CONF="/etc/pam.d/smartcard-auth"
PAM_ENV_SO="auth.*required.*pam_env\.so"
PAM_FAILLOCK_PREAUTH="auth        required      pam_faillock.so preauth silent deny=4 unlock_time=1200"
SYSTEM_AUTH_PAM_PKCS11="auth [success=done authinfo_unavail=ignore ignore=ignore default=die] pam_pkcs11.so nodebug"
PAM_FAILLOCK_AUTHFAIL="auth        required      pam_faillock.so authfail deny=4 unlock_time=1200"
sed -i --follow-symlinks -e '/^'"$PAM_ENV_SO"'/a '"$PAM_FAILLOCK_PREAUTH" "$SMARTCARD_AUTH_CONF"
sed -i --follow-symlinks -e '/^'"$SYSTEM_AUTH_PAM_PKCS11"'/a '"$PAM_FAILLOCK_AUTHFAIL" "$SMARTCARD_AUTH_CONF"
