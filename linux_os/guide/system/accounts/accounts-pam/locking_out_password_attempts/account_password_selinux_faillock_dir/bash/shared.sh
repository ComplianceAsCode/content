#!/bin/bash
# platform = multi_platform_all

FAILLOCK_CONF_FILES="/etc/security/faillock.conf /etc/pam.d/system-auth /etc/pam.d/password-auth"

for dir in $(grep -oP "^\s*(?:auth.*pam_faillock.so.*)?dir\s*=\s*(\S+)" $FAILLOCK_CONF_FILES \
            | sed -r 's/.*=\s*(\S+)/\1/'); do
    if ! `semanage fcontext -a -t faillog_t "$dir(/.*)?"`; then
        semanage fcontext -m -t faillog_t "$dir(/.*)?"
    fi
    if [ ! -e $dir ]; then
        mkdir -p $dir
    fi
    restorecon -R -v $dir
done
