#!/bin/bash
# platform = multi_platform_ubuntu

source ubuntu_common.sh

sed -i 's/\(.*pam_faillock.so.*\)/\1 audit/g' /etc/pam.d/common-auth

