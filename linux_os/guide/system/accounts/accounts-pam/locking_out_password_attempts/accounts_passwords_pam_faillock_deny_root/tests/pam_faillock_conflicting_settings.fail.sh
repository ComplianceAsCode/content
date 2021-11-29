#!/bin/bash

if [ -f /usr/sbin/authconfig ]; then
    authconfig --enablefaillock --update
else
    authselect enable-feature with-faillock
fi
sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1 even_deny_root/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
# NOTE:
# Older versions of authselect, which don't support faillock.conf will complain if any change
# is made in pam files, even for different but valid arguments. In practical, if any change in
# default pam_faillock.so parameters is necessary for hardening, old versions of authselect no
# longer can be used to manage pam. This will impact the ansible remediation for older versions
# of authselect in the specific context of this test scenario, for example, in a RHEL 8.0 and 8.1.
# However, the remediation should work properly in a realistic scenario.
> /etc/security/faillock.conf
echo "even_deny_root" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf
