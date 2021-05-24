#!/bin/bash
# platform = Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_wrlinux

retry_cnt=3
config_file="/etc/pam.d/system-auth"

if grep -q "pam_pwquality\.so.*retry=" "$config_file" ; then
	sed -i --follow-symlinks "/pam_pwquality\.so/ s/\(retry *= *\).*/\1$retry_cnt/" $config_file
else
	sed -i --follow-symlinks "/pam_pwquality\.so/ s/$/ retry=$retry_cnt/" $config_file
fi
