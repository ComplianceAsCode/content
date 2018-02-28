#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_C2S
#
# remediation = none
# Remediation for accounts_passwords_pam_faillock_deny cannot remediate this scenario
# The remediation would need to calculate number of modules to skip

cp pam_config_skip_longer /etc/pam.d/system-auth
cp pam_config_skip_longer /etc/pam.d/password-auth
