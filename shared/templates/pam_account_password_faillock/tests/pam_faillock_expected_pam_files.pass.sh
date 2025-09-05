#!/bin/bash
# packages = authconfig
# platform = Oracle Linux 7,multi_platform_fedora

{{{ tests_init_faillock_vars("correct") }}}

authconfig --enablefaillock --faillockargs="$PRM_NAME=$TEST_VALUE" --update
