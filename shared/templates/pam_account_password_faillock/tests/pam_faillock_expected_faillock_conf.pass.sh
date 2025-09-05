#!/bin/bash
# packages = authselect
# platform = multi_platform_fedora,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,Oracle Linux 8

{{{ tests_init_faillock_vars("correct", prm_name=PRM_NAME, ext_variable=EXT_VARIABLE, variable_lower_bound=VARIABLE_LOWER_BOUND, variable_upper_bound=VARIABLE_UPPER_BOUND) }}}

authselect select sssd --force
authselect enable-feature with-faillock
> /etc/security/faillock.conf
echo "$PRM_NAME = $TEST_VALUE" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf
