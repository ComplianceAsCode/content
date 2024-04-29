#!/bin/bash
# platform = multi_platform_ubuntu
# remediation = none

sed -i --follow-symlinks '/^\s*password.*pam_unix\.so/ s/sha512//g' /etc/pam.d/common-password
sed -i --follow-symlinks '/^\s*password.*pam_unix\.so/ s/$/ # sha512/' /etc/pam.d/common-password

