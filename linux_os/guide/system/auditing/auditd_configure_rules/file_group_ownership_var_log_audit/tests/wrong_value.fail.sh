#!/bin/bash

if grep -iwq "log_file" /etc/audit/auditd.conf; then
    FILE=$(awk -F "=" '/^log_file/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
else
    FILE="/var/log/audit/audit.log"
fi

sed -i "/\s*log_group.*/d" /etc/audit/auditd.conf
echo "log_group = root" >> /etc/audit/auditd.conf
touch $FILE.1
groupadd group_test
chgrp group_test $FILE.1
