#!/bin/bash
# packages = authselect,pam
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

source common.sh

for file in ${pam_files[@]}; do
    echo "auth required pam_faillock.so preauth  audit" >> "$CUSTOM_PROFILE_DIR/$file"
done

authselect apply-changes
