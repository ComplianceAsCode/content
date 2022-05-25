#!/bin/bash
# packages = audit
# platform = multi_platform_ol,multi_platform_rhel

source common_0700.sh

echo "log_file = ${DIR2}/audit.log" >> /etc/audit/auditd.conf

chmod 0750 ${DIR2}
chmod 0700 ${DIR1}
