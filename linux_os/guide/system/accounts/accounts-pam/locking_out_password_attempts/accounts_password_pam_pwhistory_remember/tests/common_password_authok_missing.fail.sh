#!/bin/bash
# platform = multi_platform_sle
# packages = pam
# variables = var_password_pam_remember=4

echo "password requisite pam_pwhistory.so remember=4" > /etc/pam.d/common-password
