#!/bin/bash

sed -i "/^\s*log_file.*/d" /etc/audit/auditd.conf

FILE1=/var/log/audit/audit.log
FILE2=/var/log/audit/audit2.log

touch ${FILE1}
touch ${FILE2}
