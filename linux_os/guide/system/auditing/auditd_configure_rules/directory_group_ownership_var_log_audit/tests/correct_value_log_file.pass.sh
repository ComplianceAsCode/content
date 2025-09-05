#!/bin/bash
# packages = audit


sed -i "/\s*log_group.*/d" /etc/audit/auditd.conf
sed -i "/\s*log_file.*/d" /etc/audit/auditd.conf
echo "log_group = root" >> /etc/audit/auditd.conf
echo "log_file = /var/log/audit2/audit.log" >> /etc/audit/auditd.conf

mkdir /var/log/audit2
groupadd group_test

chgrp root /var/log/audit2
chgrp group_test /var/log/audit
