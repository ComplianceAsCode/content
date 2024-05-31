#!/bin/bash
# platform = multi_platform_ubuntu

source ubuntu_common.sh

sed -i '/pam_faillock\.so/d' /etc/pam.d/common-auth
sed -i '/pam_faillock\.so/d' /etc/pam.d/common-account

echo "deny=1" > /etc/security/faillock.conf
