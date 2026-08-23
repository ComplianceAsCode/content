#!/bin/bash
# packages = authselect,pam
# platform = Oracle Linux 8,Oracle Linux 9,multi_platform_rhel

{{{ tests_init_faillock_vars("correct", prm_name=PRM_NAME, ext_variable=EXT_VARIABLE, variable_lower_bound=VARIABLE_LOWER_BOUND, variable_upper_bound=VARIABLE_UPPER_BOUND) }}}

pam_files=("password-auth" "system-auth")

authselect create-profile testingProfile --base-on minimal || \
    authselect create-profile testingProfile --base-on local

CUSTOM_PROFILE_DIR="/etc/authselect/custom/testingProfile"

authselect select --force custom/testingProfile

truncate -s 0 "{{{ pam_faillock_conf_path }}}"

echo "$PRM_NAME = $TEST_VALUE" > "{{{ pam_faillock_conf_path }}}"

{{{ bash_pam_faillock_enable() }}}

for file in ${pam_files[@]}; do
    if grep -qP "auth.*faillock\.so.*preauth" $CUSTOM_PROFILE_DIR/$file; then
        sed -i "/^\s*auth.*faillock\.so.*preauth/ s/$/$PRM_NAME=$TEST_VALUE/" \
            "$CUSTOM_PROFILE_DIR/$file"
    else
        sed -i "0,/^\s*auth.*/i auth required pam_faillock.so preauth $PRM_NAME=$TEST_VALUE" \
        "$CUSTOM_PROFILE_DIR/$file"
    fi
done


authselect apply-changes
