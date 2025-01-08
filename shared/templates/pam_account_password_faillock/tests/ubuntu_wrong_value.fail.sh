#!/bin/bash
# platform = multi_platform_ubuntu
# variables = var_accounts_passwords_pam_faillock_unlock_time=300

source ubuntu_common.sh

echo "unlock_time=100" > /etc/security/faillock.conf
