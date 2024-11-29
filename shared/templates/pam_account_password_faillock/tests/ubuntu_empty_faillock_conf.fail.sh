#!/bin/bash
# platform = multi_platform_ubuntu

# This test should fail because neither pam.d or faillock.conf have deny defined

source ubuntu_common.sh

rm -f /usr/share/cac_faillock*
pam-auth-update

echo > /etc/security/faillock.conf
