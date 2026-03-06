#!/bin/bash
echo "unlock_time = 0" > "{{{ pam_faillock_conf_path }}}"
authselect create-profile test_profile -b sssd
authselect select "custom/test_profile" --force
authselect enable-feature with-faillock
authselect apply-changes
