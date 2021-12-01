#!/bin/bash
# packages = authselect
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,Oracle Linux 8

authselect select sssd --force
authselect enable-feature with-faillock
# Ensure the parameters only in /etc/security/faillock.conf
sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
> /etc/security/faillock.conf
echo "even_deny_root" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf
