#!/bin/bash
# platform = multi_platform_sle
# packages = pam
# variables = var_password_pam_remember=4

echo "password requisite pam_pwhistory.so remember=1 use_authtok" > /etc/pam.d/common-password
