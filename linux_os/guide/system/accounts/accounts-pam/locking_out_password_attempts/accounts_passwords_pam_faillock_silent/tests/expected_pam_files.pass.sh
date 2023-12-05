#!/bin/bash
# packages = authselect
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

source common.sh

for file in ${pam_files[@]}; do
    sed -i --follow-symlinks "/pam_faillock\.so/s/preauth/preauth silent/" \
    "$CUSTOM_PROFILE_DIR/$file"
done

authselect apply-changes
