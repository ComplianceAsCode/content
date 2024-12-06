#!/bin/bash
# platform = multi_platform_ubuntu
# variables = var_accounts_passwords_pam_faillock_fail_interval=800

source ubuntu_common.sh

echo "fail_interval=100" > /etc/security/faillock.conf
