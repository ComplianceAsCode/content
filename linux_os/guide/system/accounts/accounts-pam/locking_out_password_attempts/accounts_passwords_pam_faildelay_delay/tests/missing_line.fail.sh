#!/bin/bash

if grep -q 'pam_faildelay.so' /etc/pam.d/common-auth; then
    sed -i --follow-symlinks "/pam_faildelay\.so/d" /etc/pam.d/common-auth
fi
