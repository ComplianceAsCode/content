#!/bin/bash
# packages = audit

sed -i "/^\s*log_file.*/d" /etc/audit/auditd.conf
echo "log_file = /var/log/audit/audit2.log" >> /etc/audit/auditd.conf

FILE="/var/log/audit/audit2.log"

useradd testuser_123
mkdir -p /var/log/audit

touch "/var/log/audit/audit.log"
chown root "/var/log/audit/audit.log"

touch "$FILE"
chown testuser_123 "$FILE"
{{% if product not in ["ol8", "rhel8"] %}}
touch "$FILE.1"
chown testuser_123 "$FILE.1"
{{% endif %}}
