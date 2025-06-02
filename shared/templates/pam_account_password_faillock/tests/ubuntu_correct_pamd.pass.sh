#!/bin/bash
# platform = multi_platform_ubuntu

{{{ tests_init_faillock_vars("correct", prm_name=PRM_NAME, ext_variable=EXT_VARIABLE, variable_lower_bound=VARIABLE_LOWER_BOUND, variable_upper_bound=VARIABLE_UPPER_BOUND) }}}

{{{ bash_enable_pam_faillock_directly_in_pam_files() }}}

sed -i 's/\(.*pam_faillock.so.*\)/\1 '$PRM_NAME'='$TEST_VALUE'/g' /etc/pam.d/common-auth

