#!/bin/bash
# packages = authselect,pam

source common.sh

for file in ${pam_files[@]}; do
    echo "auth required pam_faillock.so preauth  dir=/var/log/faillock" >> "$CUSTOM_PROFILE_DIR/$file"
    echo "auth required pam_faillock.so authfail dir=/var/log/faillock" >> "$CUSTOM_PROFILE_DIR/$file"
done

authselect apply-changes
