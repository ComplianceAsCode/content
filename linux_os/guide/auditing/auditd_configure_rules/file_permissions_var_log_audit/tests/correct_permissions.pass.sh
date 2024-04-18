#!/bin/bash
# platform = multi_platform_ubuntu
# packages = auditd

if grep -iwq "log_file" /etc/audit/auditd.conf; then
    FILE=$(awk -F "=" '/^log_file/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
else
    FILE="/var/log/audit/audit.log"
fi

touch $FILE
touch $FILE.1

chmod 0640 $FILE
chmod 0640 $FILE.*
