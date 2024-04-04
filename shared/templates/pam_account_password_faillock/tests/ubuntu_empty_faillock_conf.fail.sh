#!/bin/bash
# platform = multi_platform_ubuntu

# This test should fail because neither pam.d or faillock.conf have deny defined

source ubuntu_common.sh

echo > /etc/security/faillock.conf
