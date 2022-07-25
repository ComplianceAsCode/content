#!/bin/bash
# packages = authselect
# platform = multi_platform_fedora,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,Oracle Linux 8
# variables = var_accounts_passwords_pam_faillock_deny=3

authselect select sssd --force
authselect enable-feature with-faillock
> /etc/security/faillock.conf
echo "deny = 2" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf
