#!/bin/bash
# variables = var_accounts_passwords_pam_faillock_unlock_time=900
echo "unlock_time = 900" > "{{{ pam_faillock_conf_path }}}"
authselect enable-feature with-faillock
authselect apply-changes
