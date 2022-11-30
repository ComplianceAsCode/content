#!/bin/bash
# packages = audit
# platform = multi_platform_rhel

if grep -iwq "log_file" /etc/audit/auditd.conf; then
    FILE=$(awk -F "=" '/^log_file/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
else
    FILE="/var/log/audit/audit.log"
fi

groupadd group_test

sed -i "/\s*log_group.*/d" /etc/audit/auditd.conf
echo "log_group = group_test" >> /etc/audit/auditd.conf

touch $FILE
chgrp group_test $FILE*
