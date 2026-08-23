#!/bin/bash
# packages = policycoreutils-python-utils
# platform = multi_platform_all

truncate -s 0 /etc/security/faillock.conf
echo "dir=/var/log/faillock" > /etc/security/faillock.conf
rm -rf /var/log/faillock
