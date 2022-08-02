#!/bin/bash
# platform = multi_platform_all

FAILLOCK_DIR=$(grep -oP "^\s*(?:auth.*pam_faillock.so.*)?dir\s*=\s*(\S+)" \
                    /etc/security/faillock.conf \
                    /etc/pam.d/system-auth \
                    /etc/pam.d/password-auth \
                    | sed -r 's/.*=\s*(\S+)/\1/')

mkdir -p $FAILLOCK_DIR

semanage fcontext -a -t faillog_t "$FAILLOCK_DIR(/.*)?"

restorecon -R -v "$FAILLOCK_DIR"
