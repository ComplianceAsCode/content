#!/bin/bash
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ubuntu
# variables = var_password_pam_retry=3

source common.sh

for file in ${configuration_files[@]}; do
{{{ bash_ensure_pam_module_option('/etc/pam.d/$file',
                                   'password',
								   'required',
								   'pam_pwquality.so',
								   'retry',
								   '3',
								   '^\s*account') }}}
done
