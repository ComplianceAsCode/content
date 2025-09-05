#!/bin/bash
# packages = authselect,pam
# platform = Oracle Linux 8,Oracle Linux 9,multi_platform_rhel

source common.sh

echo "audit" >> /etc/security/faillock.conf

{{{ bash_pam_faillock_enable() }}}

