#!/bin/bash
# packages = policycoreutils-python-utils
# platform = multi_platform_all

truncate -s 0 /etc/security/faillock.conf
echo "dir=/var/log/faillock" > /etc/security/faillock.conf

mkdir /var/log/faillock
semanage fcontext -a -t faillog_t "/var/log/faillock(/.*)?"
restorecon -R -v "/var/log/faillock"
