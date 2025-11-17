#!/bin/bash
# platform = multi_platform_ubuntu

{{{ tests_init_faillock_vars("stricter", prm_name=PRM_NAME, ext_variable=EXT_VARIABLE, variable_lower_bound=VARIABLE_LOWER_BOUND, variable_upper_bound=VARIABLE_UPPER_BOUND) }}}

{{{ bash_enable_pam_faillock_directly_in_pam_files() }}}

echo "$PRM_NAME=$TEST_VALUE" > "{{{ pam_faillock_conf_path }}}"
