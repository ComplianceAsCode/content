#!/bin/bash
# platform = multi_platform_ubuntu

source ubuntu_common.sh

rm -f /usr/share/cac_faillock*
pam-auth-update

sed -i 's/\(^.*pam_faillock\.so.*\)/# \1/' /etc/pam.d/common-auth
sed -i 's/\(^.*pam_faillock\.so.*\)/# \1/' /etc/pam.d/common-account

pam-auth-update --remove faillock faillock_notify --force

echo "deny=1" > /etc/security/faillock.conf
