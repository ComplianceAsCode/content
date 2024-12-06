#!/bin/bash
# platform = multi_platform_ubuntu

{{{ tests_init_faillock_vars("lenient_low") }}}

{{{ bash_enable_pam_faillock_directly_in_pam_files() }}}

echo "$PRM_NAME=$TEST_VALUE" > /etc/security/faillock.conf
