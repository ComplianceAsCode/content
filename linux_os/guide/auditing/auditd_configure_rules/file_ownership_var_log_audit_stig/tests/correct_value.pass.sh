#!/bin/bash
# packages = audit

sed -i "/^\s*log_file.*/d" /etc/audit/auditd.conf
echo "log_file = /var/log/audit/audit2.log" >> /etc/audit/auditd.conf

useradd testuser_123
mkdir -p /var/log/audit
touch /var/log/audit/audit2.log
touch /var/log/audit/audit2.log.1
touch /var/log/audit/audit.log

chown root /var/log/audit/audit2.log*
chown testuser_123 /var/log/audit/audit.log
