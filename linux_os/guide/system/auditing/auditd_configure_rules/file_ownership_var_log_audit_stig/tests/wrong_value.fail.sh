#!/bin/bash

if grep -iwq "log_file" /etc/audit/auditd.conf; then
    FILE=$(awk -F "=" '/^log_file/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
else
    FILE="/var/log/audit/audit.log"
fi

touch $FILE.1
useradd testuser_123
chown testuser_123 $FILE.1
