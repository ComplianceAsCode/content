#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp
#
# remediation = none
# Remediation for accounts_passwords_pam_faillock_deny cannot remediate this scenario
# The remediation would need to calculate number of modules to skip

cp pam_config_skip_longer_comment /etc/pam.d/system-auth
cp pam_config_skip_longer_comment /etc/pam.d/password-auth
