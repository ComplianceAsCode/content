#!/bin/bash
#
# remediation = none
# Remediation for accounts_passwords_pam_faillock_deny cannot remediate this scenario
# The remediation would need to detect and remove default=die from pam_unix.so module

cp pam_config_default_die_pam_unix  /etc/pam.d/system-auth
cp pam_config_default_die_pam_unix  /etc/pam.d/password-auth
