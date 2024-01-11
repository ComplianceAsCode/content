#!/bin/bash
# platform = multi_platform_ubuntu

source ubuntu_common.sh

sed -i 's/\(.*pam_faillock.so.*\)/\1 deny=1/g' /etc/pam.d/common-auth

