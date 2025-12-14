#!/bin/bash
# packages = authselect
# platform = multi_platform_fedora,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,Oracle Linux 8
# remediation = none

{{{ tests_init_faillock_vars("correct", prm_name=PRM_NAME, ext_variable=EXT_VARIABLE, variable_lower_bound=VARIABLE_LOWER_BOUND, variable_upper_bound=VARIABLE_UPPER_BOUND) }}}

authselect select sssd --force
authselect enable-feature with-faillock
# This test scenario simulates conflicting settings in pam and faillock.conf files.
# It means that authselect is not properly configured and may have a unexpected behaviour. The
# authselect integrity check will fail and the remediation will be aborted in order to preserve
# intentional changes. In this case, an informative message will be shown in the remediation report.
sed -i --follow-symlinks 's/\(pam_faillock.so \(preauth silent\|authfail\)\).*$/\1 '$PRM_NAME'='$TEST_VALUE'/g' /etc/pam.d/system-auth /etc/pam.d/password-auth
> "{{{ pam_faillock_conf_path }}}"
echo "$PRM_NAME = $TEST_VALUE" >> "{{{ pam_faillock_conf_path }}}"
echo "silent" >> "{{{ pam_faillock_conf_path }}}"
