#!/bin/bash
# packages = authselect
# platform = multi_platform_fedora,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,Oracle Linux 8

{{{ tests_init_faillock_vars("stricter") }}}

authselect select sssd --force
authselect enable-feature with-faillock
> /etc/security/faillock.conf
echo "$PRM_NAME = $TEST_VALUE" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf
