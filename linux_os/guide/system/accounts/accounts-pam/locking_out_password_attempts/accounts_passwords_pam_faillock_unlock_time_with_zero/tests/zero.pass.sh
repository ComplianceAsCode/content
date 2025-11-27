#!/bin/bash
echo "unlock_time = 0" > "{{{ pam_faillock_conf_path }}}"
authselect enable-feature with-faillock
authselect apply-changes
