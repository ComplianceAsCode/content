#!/bin/bash
# packages = authselect

source common.sh

for file in ${pam_files[@]}; do
    sed -i --follow-symlinks "/pam_faillock\.so/s/preauth/preauth silent/" \
    "$CUSTOM_PROFILE_DIR/$file"
done

authselect apply-changes
