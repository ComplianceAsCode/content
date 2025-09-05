#!/bin/bash
{{{ tests_init_faillock_vars("lenient_high") }}}
# packages = authconfig
# platform = Oracle Linux 7,multi_platform_fedora


authconfig --enablefaillock --faillockargs="$PRM_NAME=$TEST_VALUE" --update
