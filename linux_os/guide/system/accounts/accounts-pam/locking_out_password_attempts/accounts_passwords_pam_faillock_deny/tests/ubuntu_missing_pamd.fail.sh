#!/bin/bash
# platform = multi_platform_ubuntu
# variables = var_accounts_passwords_pam_faillock_deny=10

echo "deny=1" > /etc/security/faillock.conf
