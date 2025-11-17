#!/bin/bash
# platform = multi_platform_fedora,multi_platform_rhel,multi_platform_ol,multi_platform_rhv,multi_platform_almalinux
# packages = authselect

{{{ tests_init_faillock_vars("correct", prm_name=PRM_NAME, ext_variable=EXT_VARIABLE, variable_lower_bound=VARIABLE_LOWER_BOUND, variable_upper_bound=VARIABLE_UPPER_BOUND) }}}

if [ -f /usr/sbin/authconfig ]; then
    authconfig --disablefaillock --update
else
    authselect select sssd --force
    authselect disable-feature with-faillock
fi
