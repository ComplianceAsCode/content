#!/bin/bash
# platform = multi_platform_all
# packages = audit

if LC_ALL=C grep -iw ^log_file /etc/audit/auditd.conf; then
  sed -i 's/^log_file.*/log_file = \/var\/log\/audit\/audit.log/' /etc/audit/auditd.conf
else
  echo "log_file = /var/log/audit/audit.log" >> /etc/audit/auditd.conf
fi

if LC_ALL=C grep -iw ^log_group /etc/audit/auditd.conf; then
  sed -i 's/^log_group.*/log_group = adm/' /etc/audit/auditd.conf
else
  echo "log_group = adm" >> /etc/audit/auditd.conf
fi

mkdir -p /var/log/audit

chmod 0750 /var/log/audit
