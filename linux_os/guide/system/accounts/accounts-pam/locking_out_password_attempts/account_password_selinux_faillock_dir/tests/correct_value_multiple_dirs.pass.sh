#!/bin/bash
# packages = policycoreutils-python-utils
# platform = multi_platform_all

truncate -s 0 /etc/security/faillock.conf
echo "dir=/var/log/faillock" > /etc/security/faillock.conf
echo "auth  required pam_faillock.so dir=/var/log/faillock_admins" >> /etc/pam.d/system-auth

mkdir /var/log/faillock /var/log/faillock_admins
semanage fcontext -a -t faillog_t "/var/log/faillock(/.*)?"
semanage fcontext -a -t faillog_t "/var/log/faillock_admins(/.*)?"
restorecon -R -v "/var/log/faillock"
restorecon -R -v "/var/log/faillock_admins"
