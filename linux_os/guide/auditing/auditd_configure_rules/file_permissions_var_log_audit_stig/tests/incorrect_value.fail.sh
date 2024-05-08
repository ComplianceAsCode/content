#!/bin/bash
# platform = multi_platform_ubuntu
# packages = audit

source common.sh

echo "log_file = ${FILE2}" >> /etc/audit/auditd.conf

chmod 0600 ${FILE1}
chmod 0640 ${FILE2}
chmod 0600 ${FILE3}
