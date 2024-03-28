#!/bin/bash
# platform = multi_platform_ubuntu
# variables = var_password_pam_unix_remember=5

config_file=/etc/pam.d/common-password
remember_cnt=5
sed -i "s/password.*pam_unix.so.*/password [success=1 default=ignore] pam_unix.so obscure sha512 shadow remember=${remember_cnt} rounds=5000/" "${config_file}"
