#!/bin/bash
# platform = multi_platform_ubuntu

{{{ tests_init_faillock_vars("correct") }}}

echo "$PRM_NAME=$TEST_VALUE" > /etc/security/faillock.conf
