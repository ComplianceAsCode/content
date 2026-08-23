#!/bin/bash
# variables = var_accounts_passwords_pam_faillock_unlock_time=900
echo "unlock_time = 1000" > "{{{ pam_faillock_conf_path }}}"
authselect create-profile test_profile -b sssd
authselect select "custom/test_profile" --force
authselect enable-feature with-faillock
authselect apply-changes
