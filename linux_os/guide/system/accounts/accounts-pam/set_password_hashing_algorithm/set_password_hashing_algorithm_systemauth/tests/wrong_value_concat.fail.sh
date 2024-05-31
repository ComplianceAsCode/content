#!/bin/bash
# platform = multi_platform_ubuntu

sed -i --follow-symlinks '/^\s*password.*pam_unix\.so/ s/sha512//g' /etc/pam.d/common-password
sed -i --follow-symlinks '/^\s*password.*pam_unix\.so/ s/$/ sha5122/' /etc/pam.d/common-password

