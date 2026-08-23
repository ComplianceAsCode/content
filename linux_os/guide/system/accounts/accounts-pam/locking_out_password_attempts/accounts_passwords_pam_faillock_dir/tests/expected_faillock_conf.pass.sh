#!/bin/bash
# packages = authselect,pam
# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

source common.sh

echo "dir = /var/log/faillock" >> /etc/security/faillock.conf

{{{ bash_pam_faillock_enable() }}}
