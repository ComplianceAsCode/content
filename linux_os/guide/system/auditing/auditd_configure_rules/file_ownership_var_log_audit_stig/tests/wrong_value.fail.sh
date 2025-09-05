#!/bin/bash
# packages = audit

sed -i "/^\s*log_file.*/d" /etc/audit/auditd.conf
echo "log_file = /var/log/audit/audit2.log" >> /etc/audit/auditd.conf

if grep -iwq "log_file" /etc/audit/auditd.conf; then
    FILE=$(awk -F "=" '/^log_file/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
else
    FILE="/var/log/audit/audit.log"
fi

useradd testuser_123

touch "/var/log/audit/audit.log"
chown root "/var/log/audit/audit.log"

{{% if product in ["ol8", "rhel8"] %}}
touch $FILE
chown testuser_123 $FILE
{{% else %}}
touch $FILE.1
chown testuser_123 $FILE.1
{{% endif %}}
