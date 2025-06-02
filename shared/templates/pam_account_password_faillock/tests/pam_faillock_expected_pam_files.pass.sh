#!/bin/bash
# packages = authconfig
# platform = Oracle Linux 7,multi_platform_fedora

{{{ tests_init_faillock_vars("correct", prm_name=PRM_NAME, ext_variable=EXT_VARIABLE, variable_lower_bound=VARIABLE_LOWER_BOUND, variable_upper_bound=VARIABLE_UPPER_BOUND) }}}

authconfig --enablefaillock --faillockargs="$PRM_NAME=$TEST_VALUE" --update
