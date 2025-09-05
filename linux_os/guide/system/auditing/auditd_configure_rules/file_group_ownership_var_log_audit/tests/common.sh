#!/bin/bash

sed -i "/^\s*log_file.*/d" /etc/audit/auditd.conf
sed -i "/^\s*log_group.*/d" /etc/audit/auditd.conf

groupadd group_test
rm -f /var/log/audit/*
mkdir /var/log/audit2/

FILE1=/var/log/audit/audit.log
FILE2=/var/log/audit2/audit.log

touch ${FILE1}
touch ${FILE2}
