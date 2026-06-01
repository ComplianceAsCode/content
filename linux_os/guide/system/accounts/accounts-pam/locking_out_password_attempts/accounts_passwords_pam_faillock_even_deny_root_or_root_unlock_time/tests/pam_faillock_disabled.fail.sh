#!/bin/bash
# packages = authselect
# platform = multi_platform_rhel,multi_platform_fedora
# variables = var_accounts_passwords_pam_faillock_root_unlock_time=60

authselect select sssd --force
authselect disable-feature with-faillock
