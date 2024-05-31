#!/bin/bash

sed -i "/^\s*log_file.*/d" /etc/audit/auditd.conf

FILE1=/var/log/audit/audit.log
FILE2=/var/log/audit2/audit.log
FILE3=/var/log/audit2/audit.log.1

for f in $FILE1 $FILE2 $FILE3; do
    mkdir -p $(dirname $f)
    touch $f
done
