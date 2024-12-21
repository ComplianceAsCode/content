#!/bin/bash
# platform = multi_platform_ubuntu

config_file=/etc/pam.d/common-password
sed -i --follow-symlinks "s/use_authtok//g" $config_file
