#!/bin/bash
# platform = multi_platform_ubuntu
# variables = var_accounts_passwords_pam_faillock_fail_interval=800

echo "fail_interval=900" > /etc/security/faillock.conf
