#!/bin/bash
# packages = audit

sed -i "/^\s*log_file.*/d" /etc/audit/auditd.conf
echo "log_file = /var/log/audit/audit2.log" >> /etc/audit/auditd.conf

if LC_ALL=C grep -iqE '^[[:space:]]*log_file\b' /etc/audit/auditd.conf; then
    FILE=$(awk -F "=" '/^[[:space:]]*log_file[[:space:]]*=/ {print $2}' /etc/audit/auditd.conf | tr -d ' ')
fi

FILE=${FILE:-/var/log/audit/audit.log}

useradd testuser_123

touch "/var/log/audit/audit.log"
chown root "/var/log/audit/audit.log"

{{% if product in ["ol8", "rhel8"] %}}
for f in $FILE; do
    touch "$f"
    chown testuser_123 "$f"
done
{{% else %}}
for f in $FILE; do
    touch "${f}.1"
    chown testuser_123 "${f}.1"
done
{{% endif %}}
