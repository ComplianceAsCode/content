#!/bin/bash

sed -i "/\s*log_file.*/d" /etc/audit/auditd.conf
echo "log_file = /var/log/audit2/audit.log" >> /etc/audit/auditd.conf

mkdir /var/log/audit2
touch /var/log/audit2/audit.log
useradd testuser_123
chown testuser_123 /var/log/audit2
