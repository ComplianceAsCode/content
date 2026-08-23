#!/bin/bash
# packages = authselect
# platform = multi_platform_rhel,multi_platform_fedora
# variables = var_accounts_passwords_pam_faillock_root_unlock_time=60

authselect select sssd --force
authselect enable-feature with-faillock
> "{{{ pam_faillock_conf_path }}}"
echo "root_unlock_time = 300" >> "{{{ pam_faillock_conf_path }}}"
echo "silent" >> "{{{ pam_faillock_conf_path }}}"
