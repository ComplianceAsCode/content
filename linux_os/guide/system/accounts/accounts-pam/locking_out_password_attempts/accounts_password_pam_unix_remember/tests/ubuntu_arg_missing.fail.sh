#!/bin/bash
# platform = multi_platform_ubuntu

config_file=/etc/pam.d/common-password
if grep -q "pam_unix\.so.*remember=" "${config_file}" ; then
    sed -i "/pam_unix\.so/ s/\bremember=\S*//" "${config_file}"
fi
