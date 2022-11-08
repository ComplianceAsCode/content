#!/bin/bash
# packages = authselect,pam
# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

source common.sh

echo "dir = /var/log/faillock" > /etc/security/pam_faillock.conf

{{{ bash_pam_faillock_enable() }}}

for file in ${pam_files[@]}; do
    if grep -q "pam_faillock\.so.*dir=" "$CUSTOM_PROFILE_DIR/$file" ; then
        echo "auth required pam_faillock.so preauth dir=/var/log/faillock" >> \
        "$CUSTOM_PROFILE_DIR/$file"
    fi
done

authselect apply-changes
