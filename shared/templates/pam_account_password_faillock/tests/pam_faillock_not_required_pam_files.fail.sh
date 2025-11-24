#!/bin/bash
# platform = multi_platform_fedora,multi_platform_rhel,multi_platform_ol,multi_platform_rhv,multi_platform_sle,multi_platform_almalinux
# packages = authselect
# remediation = none

{{{ tests_init_faillock_vars("correct", prm_name=PRM_NAME, ext_variable=EXT_VARIABLE, variable_lower_bound=VARIABLE_LOWER_BOUND, variable_upper_bound=VARIABLE_UPPER_BOUND) }}}

# This test scenario manually modify the pam_faillock.so entries in auth section from
# "required" to "sufficient". This makes pam_faillock.so behave differently than initially
# intentioned. We catch this, but we can't safely remediate in an automated way.
if [ -f /usr/sbin/authconfig ]; then
    authconfig --enablefaillock --faillockargs="$PRM_NAME=$TEST_VALUE" --update
else
    authselect select sssd --force
    authselect enable-feature with-faillock
    sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1 '$PRM_NAME'='$TEST_VALUE'/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
fi
sed -i --follow-symlinks 's/\(^\s*auth\s*\)\(\s.*\)\(pam_faillock\.so.*$\)/\1 sufficient \3/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
if [ -f "{{{ pam_faillock_conf_path }}}" ]; then
    > "{{{ pam_faillock_conf_path }}}"
fi
