#!/bin/bash
# packages = authselect,pam
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

pam_files=("password-auth" "system-auth")

authselect create-profile testingProfile --base-on minimal

CUSTOM_PROFILE_DIR="/etc/authselect/custom/testingProfile"

authselect select --force custom/testingProfile

truncate -s 0 /etc/security/faillock.conf

echo "even_deny_root" > /etc/security/faillock.conf

{{{ bash_pam_faillock_enable() }}}

for file in ${pam_files[@]}; do
    if grep -qP "auth.*faillock\.so.*preauth" $CUSTOM_PROFILE_DIR/$file; then
        sed -i "/^\s*auth.*faillock\.so.*preauth/ s/$/even_deny_root/" \
            "$CUSTOM_PROFILE_DIR/$file"
    else 
        sed -i "0,/^\s*auth.*/i auth required pam_faillock.so preauth even_deny_root" \
        "$CUSTOM_PROFILE_DIR/$file"
    fi
done

authselect apply-changes
