#!/bin/bash
# platform = multi_platform_ubuntu

source ubuntu_common.sh

sed -i 's/\(^.*pam_faillock\.so.*\)/# \1/' /etc/pam.d/common-auth
sed -i 's/\(^.*pam_faillock\.so.*\)/# \1/' /etc/pam.d/common-account

echo "#audit" > /etc/security/faillock.conf
