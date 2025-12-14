#!/bin/bash
{{{ tests_init_faillock_vars("lenient_low", prm_name=PRM_NAME, ext_variable=EXT_VARIABLE, variable_lower_bound=VARIABLE_LOWER_BOUND, variable_upper_bound=VARIABLE_UPPER_BOUND) }}}
# packages = authselect
# platform = multi_platform_fedora,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,Oracle Linux 8


authselect select sssd --force
authselect enable-feature with-faillock
> "{{{ pam_faillock_conf_path }}}"
echo "$PRM_NAME = $TEST_VALUE" >> "{{{ pam_faillock_conf_path }}}"
echo "silent" >> "{{{ pam_faillock_conf_path }}}"
